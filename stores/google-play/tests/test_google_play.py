"""Offline tests for the narrow Google Play CLI workflow."""

from __future__ import annotations

import contextlib
import hashlib
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
import types
import unittest
from pathlib import Path
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "google_play.py"
WRAPPER = Path(__file__).resolve().parents[3] / ".devtools" / "google_play.sh"
SPEC = importlib.util.spec_from_file_location("google_play", SCRIPT)
assert SPEC and SPEC.loader
google_play = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(google_play)


class FakeResponse:
    def __init__(self, value):
        self.value = value

    def execute(self):
        if isinstance(self.value, BaseException):
            raise self.value
        return self.value


class FakeUploadRequest:
    def __init__(self, value):
        self.value = value

    def next_chunk(self, num_retries=0):
        return None, self.value


class FakeTrackResource:
    def __init__(self, service):
        self.service = service

    def list(self, **_kwargs):
        if self.service.verification_error and self.service.committed:
            return FakeResponse(self.service.verification_error)
        return FakeResponse({"tracks": self.service.current_tracks})

    def update(self, **kwargs):
        self.service.track_updates.append(kwargs)
        return FakeResponse({})


class FakeBundleResource:
    def __init__(self, service):
        self.service = service

    def list(self, **_kwargs):
        return FakeResponse({"bundles": self.service.bundle_items})

    def upload(self, **_kwargs):
        self.service.upload_calls += 1
        return FakeUploadRequest(self.service.uploaded)


class FakeHttpError(Exception):
    def __init__(self, status, message):
        super().__init__(message)
        self.resp = types.SimpleNamespace(status=status)
        self.content = json.dumps({"error": {"message": message}}).encode()


class FakeService:
    """Implements only the Android Publisher resources used by the CLI."""

    def __init__(
        self,
        *,
        bundles=None,
        commit_error=None,
        commit_applies=False,
        uploaded=None,
        verification_error=None,
    ):
        self.bundle_items = bundles or []
        self.commit_error = commit_error
        self.commit_applies = commit_applies
        self.uploaded = uploaded
        self.verification_error = verification_error
        self.committed = False
        self.track_updates = []
        self.upload_calls = 0
        self.current_tracks = [{"track": "alpha", "releases": []}]
        self._next_edit = 0

    def edits(self):
        return self

    def insert(self, **_kwargs):
        self._next_edit += 1
        return FakeResponse({"id": f"edit-{self._next_edit}"})

    def delete(self, **_kwargs):
        return FakeResponse({})

    def tracks(self):
        return FakeTrackResource(self)

    def bundles(self):
        return FakeBundleResource(self)

    def validate(self, **_kwargs):
        return FakeResponse({})

    def commit(self, **_kwargs):
        if self.commit_error:
            if self.commit_applies:
                self.committed = True
                self.current_tracks = [
                    {
                        "track": "alpha",
                        "releases": [
                            {
                                "name": "8",
                                "versionCodes": ["8"],
                                "status": "completed",
                            }
                        ],
                    }
                ]
            return FakeResponse(self.commit_error)
        self.current_tracks = [
            {
                "track": "alpha",
                "releases": [
                    {
                        "name": "8",
                        "versionCodes": ["8"],
                        "status": "completed",
                    }
                ],
            }
        ]
        self.committed = True
        return FakeResponse({"id": "committed"})


class GooglePlayCliTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.artifact = Path(self.tempdir.name) / "candidate.aab"
        self.artifact.write_bytes(b"offline fake AAB bytes")
        self.sha256 = hashlib.sha256(self.artifact.read_bytes()).hexdigest()
        self.config = {
            "packageName": "com.example.offline",
            "tracks": {"closed": {"apiKey": "alpha", "resolveFromApi": True}},
        }
        self._google_api_modules = self._media_file_upload_modules()
        self.addCleanup(self._google_api_modules.__exit__, None, None, None)
        self._google_api_modules.__enter__()

    @staticmethod
    def _media_file_upload_modules():
        package = types.ModuleType("googleapiclient")
        http_module = types.ModuleType("googleapiclient.http")
        http_module.MediaFileUpload = lambda *args, **kwargs: (args, kwargs)
        package.http = http_module
        return mock.patch.dict(
            sys.modules,
            {"googleapiclient": package, "googleapiclient.http": http_module},
        )

    def service(self, **kwargs):
        return FakeService(
            uploaded={"versionCode": "8", "sha256": self.sha256}, **kwargs
        )

    def run_upload_cli(self, service):
        stdout = io.StringIO()
        stderr = io.StringIO()
        with (
            mock.patch.object(google_play, "load_config", return_value=self.config),
            mock.patch.object(google_play, "build_service", return_value=service),
            mock.patch.object(
                sys,
                "argv",
                ["google_play.py", "upload-closed", "--aab", str(self.artifact), "--version-code", "8"],
            ),
            contextlib.redirect_stdout(stdout),
            contextlib.redirect_stderr(stderr),
        ):
            result = google_play.main()
        return result, stdout.getvalue(), stderr.getvalue()

    def test_successful_upload_emits_valid_json_with_path(self):
        service = self.service()

        result, stdout, _stderr = self.run_upload_cli(service)

        self.assertEqual(result, 0)
        output = json.loads(stdout)
        self.assertEqual(output["versionCode"], "8")
        self.assertEqual(output["artifact"], str(self.artifact.resolve()))
        self.assertEqual(output["playSha256"], self.sha256)
        self.assertEqual(len(service.track_updates), 1)

    def test_duplicate_bundle_code_rejects_before_upload(self):
        service = self.service(bundles=[{"versionCode": 8}])
        candidate = google_play.validate_candidate(self.config, self.artifact, "8")

        with self.assertRaisesRegex(RuntimeError, "already exists"):
            google_play.upload_closed_aab(service, self.config, candidate, None)

        self.assertEqual(service.upload_calls, 0)
        self.assertEqual(service.track_updates, [])

    def test_play_hash_mismatch_does_not_update_track(self):
        service = FakeService(uploaded={"versionCode": "8", "sha256": "00" * 32})
        candidate = google_play.validate_candidate(self.config, self.artifact, "8")

        with self.assertRaisesRegex(RuntimeError, "SHA-256 does not match"):
            google_play.upload_closed_aab(service, self.config, candidate, None)

        self.assertEqual(service.upload_calls, 1)
        self.assertEqual(service.track_updates, [])

    def test_lost_commit_response_accepts_fresh_completed_track(self):
        service = self.service(
            commit_error=TimeoutError("connection dropped after commit"),
            commit_applies=True,
        )
        candidate = google_play.validate_candidate(self.config, self.artifact, "8")

        result = google_play.upload_closed_aab(service, self.config, candidate, None)

        self.assertTrue(result["commit"]["verifiedAfterAmbiguousCommit"])
        self.assertEqual(len(service.track_updates), 1)

    def test_committed_release_with_failed_verification_warns_do_not_reupload(self):
        service = self.service(verification_error=TimeoutError("verification unavailable"))

        result, _stdout, stderr = self.run_upload_cli(service)

        self.assertEqual(result, 1)
        self.assertIn("edit committed", stderr)
        self.assertIn("Do not re-upload", stderr)
        self.assertTrue(service.committed)
        self.assertEqual(service.upload_calls, 1)
        self.assertEqual(len(service.track_updates), 1)

    def test_pending_review_failure_preserves_api_detail(self):
        detail = "You already have changes in review; wait for review to complete."
        service = self.service(commit_error=FakeHttpError(400, detail))

        result, _stdout, stderr = self.run_upload_cli(service)

        self.assertEqual(result, 1)
        self.assertIn(detail, stderr)
        self.assertIn("HTTP 400", stderr)
        self.assertEqual(len(service.track_updates), 1)

    def test_upload_rejects_non_alpha_mapping_before_opening_edit(self):
        config = {
            "packageName": "com.example.offline",
            "tracks": {"closed": {"apiKey": "beta", "resolveFromApi": True}},
        }
        service = self.service()
        candidate = google_play.validate_candidate(config, self.artifact, "8")

        with self.assertRaisesRegex(RuntimeError, "Closed Alpha"):
            google_play.upload_closed_aab(service, config, candidate, None)

        self.assertEqual(service._next_edit, 0)
        self.assertEqual(service.upload_calls, 0)

    def test_wrapper_help_does_not_require_credentials_or_virtualenv(self):
        env = os.environ.copy()
        env.pop("GOOGLE_APPLICATION_CREDENTIALS", None)
        env["GOOGLE_PLAY_VENV_DIR"] = str(Path(self.tempdir.name) / "missing-venv")

        completed = subprocess.run(
            ["bash", str(WRAPPER), "--help"],
            cwd=WRAPPER.parents[1],
            env=env,
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertIn("usage:", completed.stdout.lower())
        self.assertIn("upload-closed", completed.stdout)

    def test_package_lock_blocks_subprocess_and_releases_after_exception(self):
        package_name = "com.example.offline.lock-test"
        child_code = (
            "import importlib.util,sys; "
            "spec=importlib.util.spec_from_file_location('google_play',sys.argv[1]); "
            "module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); "
            "lock=module.play_operation_lock(sys.argv[2]); "
            "lock.__enter__(); print('acquired',flush=True); lock.__exit__(None,None,None)"
        )

        def acquire_in_subprocess():
            return subprocess.run(
                [sys.executable, "-c", child_code, str(SCRIPT), package_name],
                check=False,
                capture_output=True,
                text=True,
            )

        with google_play.play_operation_lock(package_name):
            blocked = acquire_in_subprocess()
        self.assertNotEqual(blocked.returncode, 0)
        self.assertIn("Another local Play command", blocked.stderr)

        with self.assertRaisesRegex(RuntimeError, "simulated command failure"):
            with google_play.play_operation_lock(package_name):
                raise RuntimeError("simulated command failure")

        acquired = acquire_in_subprocess()
        self.assertEqual(acquired.returncode, 0, acquired.stderr)
        self.assertIn("acquired", acquired.stdout)


if __name__ == "__main__":
    unittest.main()
