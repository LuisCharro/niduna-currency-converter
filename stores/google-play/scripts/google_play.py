#!/usr/bin/env python3
"""Inspect and safely update the configured Google Play testing track."""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
import sys
import tempfile
from pathlib import Path
from typing import Any


CONFIG_PATH = Path(__file__).resolve().parents[1] / "apps" / "currency-converter.json"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"


def load_config() -> dict[str, Any]:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


@contextmanager
def play_operation_lock(package_name: str):
    """Serialize edits across local checkouts; a new API edit invalidates the old one."""
    lock_name = f"honestfern-play-{os.getuid()}-{package_name}.lock"
    descriptor = os.open(Path(tempfile.gettempdir()) / lock_name, os.O_CREAT | os.O_RDWR, 0o600)
    with os.fdopen(descriptor, "w") as lock_file:
        try:
            fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError(
                "Another local Play command is using this app. Wait for it to finish; "
                "status/preflight must not run alongside uploads."
            ) from error
        try:
            yield
        finally:
            fcntl.flock(lock_file, fcntl.LOCK_UN)


def build_service() -> Any:
    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        raise RuntimeError(
            "Set GOOGLE_APPLICATION_CREDENTIALS to the existing service-account JSON path."
        )
    try:
        import google.auth
        import google_auth_httplib2
        from googleapiclient.discovery import build
        from googleapiclient.http import build_http
    except ImportError as error:
        raise RuntimeError(
            "Missing Python dependencies. Run ./.devtools/google_play.sh setup; "
            "do not put credentials in the repository."
        ) from error

    credentials, _ = google.auth.default(scopes=[SCOPE])
    # Google's transport leaves HTTP 308 to the resumable upload handler.
    # A raw httplib2.Http treats it as a redirect and can require a missing Location.
    transport = build_http()
    transport.timeout = 180
    authorized_http = google_auth_httplib2.AuthorizedHttp(credentials, http=transport)
    return build(
        "androidpublisher", "v3", http=authorized_http, cache_discovery=False
    )


def with_verification_edit(service: Any, package_name: str, read_tracks: bool) -> list[dict[str, Any]]:
    edit_id: str | None = None
    try:
        edit_id = service.edits().insert(packageName=package_name, body={}).execute()["id"]
        if not read_tracks:
            return []
        response = service.edits().tracks().list(
            packageName=package_name, editId=edit_id
        ).execute()
        return response.get("tracks", [])
    finally:
        if edit_id is not None:
            delete_edit(service, package_name, edit_id)


def delete_edit(service: Any, package_name: str, edit_id: str) -> None:
    operation_failed = sys.exc_info()[0] is not None
    try:
        service.edits().delete(packageName=package_name, editId=edit_id).execute()
    except Exception as cleanup_error:
        if operation_failed:
            print(
                "Google Play: temporary edit cleanup also failed; inspect Console/status before retrying.",
                file=sys.stderr,
            )
            return
        raise RuntimeError(
            "Could not delete the temporary Play edit; inspect Console/status before retrying."
        ) from cleanup_error


def summarize_track(track: dict[str, Any]) -> dict[str, Any]:
    releases = []
    for release in track.get("releases", []):
        releases.append(
            {
                "name": release.get("name"),
                "status": release.get("status"),
                "versionCodes": release.get("versionCodes", []),
                "userFraction": release.get("userFraction"),
            }
        )
    return {"track": track.get("track"), "releases": releases}


def has_completed_release(
    tracks: list[dict[str, Any]],
    track_key: str,
    version_code: str,
    release_name: str,
) -> bool:
    return any(
        release.get("status") == "completed"
        and release.get("name") == release_name
        and version_code in {str(code) for code in release.get("versionCodes", [])}
        for track in tracks
        if track.get("track") == track_key
        for release in track.get("releases", [])
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as artifact:
        for chunk in iter(lambda: artifact.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def closed_track_key(config: dict[str, Any]) -> str:
    closed_track = config["tracks"]["closed"]
    expected_track = closed_track.get("apiKey")
    if expected_track != "alpha" or not closed_track.get("resolveFromApi"):
        raise RuntimeError(
            "This uploader is limited to the live-verified Closed Alpha API track."
        )
    return expected_track


def api_error_hint(status: int | None) -> str:
    return {
        400: "Check the API validation/review message and current Console state before retrying.",
        403: "Check app-scoped Play permissions; do not widen account access as a first response.",
        404: "Recheck package name and the live API track key in the app mapping.",
        409: "Another edit may have changed Play state; rerun status and preflight.",
    }.get(
        status,
        "For a 5xx or timeout, read live track state before retrying; the outcome may be ambiguous."
        if status is None or status >= 500
        else "See the publishing runbook for recovery.",
    )


def safe_api_error_message(error: Exception) -> str:
    content = getattr(error, "content", b"")
    try:
        if isinstance(content, bytes):
            content = content.decode("utf-8", errors="replace")
        body = json.loads(content).get("error", {})
        message = " ".join(str(body.get("message", "")).split())
    except (TypeError, ValueError, AttributeError):
        return ""
    return message[:400]


def validate_candidate(
    config: dict[str, Any], artifact: Path, version_code: str
) -> dict[str, Any]:
    if not artifact.is_file() or artifact.suffix.lower() != ".aab":
        raise RuntimeError("Provide an existing .aab bundle.")
    if not version_code.isdigit() or int(version_code) <= 0:
        raise RuntimeError("Version code must be a positive integer.")

    expected_name = None
    if config.get("versionSource") == "pubspec.yaml":
        pubspec = Path(__file__).resolve().parents[3] / "pubspec.yaml"
        version_line = next(
            (line.split(":", 1)[1].strip() for line in pubspec.read_text().splitlines()
             if line.startswith("version:")),
            "",
        )
        if "+" not in version_line:
            raise RuntimeError("pubspec.yaml version must include an Android version code.")
        version_name, configured_code = version_line.rsplit("+", 1)
        if configured_code != version_code:
            raise RuntimeError(
                f"Requested version code {version_code} does not match pubspec.yaml ({configured_code})."
            )
        expected_name = f"{version_name} ({version_code})"

    return {
        "artifact": str(artifact.resolve()),
        "versionCode": version_code,
        "releaseName": expected_name or version_code,
        "sizeBytes": artifact.stat().st_size,
        "sha256": sha256_file(artifact),
    }


def inspect_closed_track(
    service: Any, config: dict[str, Any], version_code: str
) -> dict[str, Any]:
    package_name = config["packageName"]
    expected_track = closed_track_key(config)

    edit_id: str | None = None
    try:
        edit_id = service.edits().insert(packageName=package_name, body={}).execute()["id"]
        tracks = service.edits().tracks().list(
            packageName=package_name, editId=edit_id
        ).execute().get("tracks", [])
        track = next(
            (item for item in tracks if item.get("track") == expected_track), None
        )
        if track is None:
            raise RuntimeError(
                f"Configured Closed Alpha API track {expected_track!r} is absent from the live track list."
            )

        bundles = service.edits().bundles().list(
            packageName=package_name, editId=edit_id
        ).execute().get("bundles", [])
        bundle_codes = {str(bundle.get("versionCode")) for bundle in bundles}
        release_codes = {
            str(code)
            for item in tracks
            for release in item.get("releases", [])
            for code in release.get("versionCodes", [])
        }
        if version_code in bundle_codes or version_code in release_codes:
            raise RuntimeError(
                f"Version code {version_code} already exists in Play bundles or track releases."
            )
        return {
            "track": expected_track,
            "usedBundleCount": len(bundles),
            "tracks": [summarize_track(item) for item in tracks],
        }
    finally:
        if edit_id is not None:
            delete_edit(service, package_name, edit_id)


def upload_closed_aab(
    service: Any,
    config: dict[str, Any],
    candidate: dict[str, Any],
    release_notes: str | None,
) -> dict[str, Any]:
    """Upload a bundle to the configured Closed Alpha track in one edit."""
    package_name = config["packageName"]
    version_code = candidate["versionCode"]
    release_name = candidate["releaseName"]
    artifact = candidate["artifact"]
    expected_track = closed_track_key(config)

    edit_id: str | None = None
    try:
        edit_id = service.edits().insert(packageName=package_name, body={}).execute()["id"]
        tracks = service.edits().tracks().list(
            packageName=package_name, editId=edit_id
        ).execute().get("tracks", [])
        api_track = next(
            (track.get("track") for track in tracks
             if track.get("track") == expected_track), None
        )
        if not api_track:
            raise RuntimeError(
                f"Configured Closed Alpha API track {expected_track!r} is absent from the live track list."
            )
        bundles = service.edits().bundles().list(
            packageName=package_name, editId=edit_id
        ).execute().get("bundles", [])
        used_codes = {
            str(bundle.get("versionCode")) for bundle in bundles
        } | {
            str(code)
            for track in tracks
            for release in track.get("releases", [])
            for code in release.get("versionCodes", [])
        }
        if version_code in used_codes:
            raise RuntimeError(
                f"Version code {version_code} already exists in Play bundles or track releases."
            )

        from googleapiclient.http import MediaFileUpload

        upload_request = service.edits().bundles().upload(
            packageName=package_name,
            editId=edit_id,
            media_body=MediaFileUpload(
                str(artifact), mimetype="application/octet-stream", resumable=True,
                chunksize=8 * 1024 * 1024,
            ),
        )
        uploaded = None
        while uploaded is None:
            progress, uploaded = upload_request.next_chunk(num_retries=3)
            if progress is not None:
                print(
                    f"Uploading AAB: {progress.progress() * 100:.0f}%",
                    file=sys.stderr,
                    flush=True,
                )
        if str(uploaded.get("versionCode")) != version_code:
            raise RuntimeError(
                f"Uploaded bundle reports version code {uploaded.get('versionCode')}; expected {version_code}."
            )
        if (uploaded.get("sha256") or "").lower() != candidate["sha256"]:
            raise RuntimeError(
                "Google Play's uploaded bundle SHA-256 does not match the local AAB."
            )

        release: dict[str, Any] = {
            "name": release_name,
            "versionCodes": [version_code],
            "status": "completed",
        }
        if release_notes:
            release["releaseNotes"] = [
                {"language": config.get("defaultLocale", "en-GB"), "text": release_notes}
            ]
        service.edits().tracks().update(
            packageName=package_name,
            editId=edit_id,
            track=api_track,
            body={"track": api_track, "releases": [release]},
        ).execute()
        service.edits().validate(
            packageName=package_name, editId=edit_id
        ).execute()
        try:
            committed = service.edits().commit(
                packageName=package_name,
                editId=edit_id,
                changesInReviewBehavior="ERROR_IF_IN_REVIEW",
            ).execute()
        except Exception as commit_error:
            status = getattr(getattr(commit_error, "resp", None), "status", None)
            if status is not None and 400 <= status < 500:
                # A definite rejection needs its original Google message, not an
                # ambiguous-outcome wrapper or a second edit.
                raise
            # Creating a verification edit invalidates any prior edit for this
            # account. Never try to delete the old ID afterwards.
            edit_id = None
            try:
                fresh_tracks = with_verification_edit(
                    service, package_name, read_tracks=True
                )
            except Exception as verification_error:
                edit_id = None
                raise RuntimeError(
                    "Commit response was ambiguous and a fresh track read failed. "
                    "Inspect Play Console/status before retrying; no automatic retry occurred."
                ) from verification_error
            if has_completed_release(
                fresh_tracks, api_track, version_code, release_name
            ):
                committed = {"verifiedAfterAmbiguousCommit": True}
            else:
                raise RuntimeError(
                    "Commit failed and a fresh track read does not show the release. "
                    "Do not retry until the state is reviewed."
                ) from commit_error
        edit_id = None
        if not committed.get("verifiedAfterAmbiguousCommit"):
            try:
                fresh_tracks = with_verification_edit(service, package_name, read_tracks=True)
                if not has_completed_release(fresh_tracks, api_track, version_code, release_name):
                    raise RuntimeError("Expected release is absent from fresh track state.")
            except Exception as verification_error:
                raise RuntimeError(
                    "The edit committed, but fresh verification failed. Do not re-upload; "
                    "inspect status/Console to resolve the outcome."
                ) from verification_error
        return {
            "track": api_track,
            "versionCode": version_code,
            "releaseName": release_name,
            **candidate,
            "playSha256": uploaded["sha256"],
            "commit": committed,
            "verifiedTrack": True,
        }
    finally:
        if edit_id is not None:
            delete_edit(service, package_name, edit_id)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "command", choices=("status", "verify-access", "plan-closed", "upload-closed")
    )
    parser.add_argument("--aab", type=Path, help="Signed AAB for Closed Alpha preflight/upload.")
    parser.add_argument("--version-code", help="Expected Play version code; must match pubspec and the uploaded AAB.")
    parser.add_argument("--release-notes", help="Optional release notes in the configured default locale.")
    args = parser.parse_args()

    if args.command in {"plan-closed", "upload-closed"} and (
        not args.aab or not args.version_code
    ):
        parser.error(f"{args.command} requires --aab and --version-code")
    if args.command != "upload-closed" and args.release_notes:
        parser.error("--release-notes is only valid with upload-closed")
    if args.command not in {"plan-closed", "upload-closed"} and any(
        (args.aab, args.version_code)
    ):
        parser.error("candidate options are only valid with plan-closed or upload-closed")

    try:
        config = load_config()
        candidate = None
        if args.command in {"plan-closed", "upload-closed"}:
            candidate = validate_candidate(
                config, args.aab, args.version_code
            )
        with play_operation_lock(config["packageName"]):
            service = build_service()
            if args.command == "plan-closed":
                live = inspect_closed_track(service, config, candidate["versionCode"])
                print(json.dumps({**candidate, **live}, indent=2, default=str))
                return 0
            if args.command == "upload-closed":
                result = upload_closed_aab(
                    service, config, candidate, args.release_notes,
                )
                tracks = []
            else:
                tracks = with_verification_edit(
                    service,
                    config["packageName"],
                    read_tracks=args.command == "status",
                )
    except Exception as error:  # API/credential exceptions can include private paths or request details
        if isinstance(error, RuntimeError):
            print(f"Google Play {args.command} failed: {error}", file=sys.stderr)
            return 1
        status = getattr(getattr(error, "resp", None), "status", None)
        api_status = f", HTTP {status}" if status else ""
        api_message = safe_api_error_message(error)
        detail = f" Google: {api_message}" if api_message else ""
        print(
            f"Google Play {args.command} failed ({type(error).__name__}{api_status}). "
            f"{api_error_hint(status)}{detail}",
            file=sys.stderr,
        )
        return 1

    if args.command == "verify-access":
        print(f"Access verified for {config['packageName']}; temporary edit deleted.")
    elif args.command == "upload-closed":
        print(json.dumps(result, indent=2))
    else:
        print(json.dumps([summarize_track(track) for track in tracks], indent=2))
        print("Temporary read edit deleted. No track or listing changes were made.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
