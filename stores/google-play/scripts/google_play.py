#!/usr/bin/env python3
"""Read Google Play track state through a temporary Android Publisher edit."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from pathlib import Path
from typing import Any


CONFIG_PATH = Path(__file__).resolve().parents[1] / "apps" / "currency-converter.json"
SCOPE = "https://www.googleapis.com/auth/androidpublisher"


def load_config() -> dict[str, Any]:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def build_service() -> Any:
    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        raise RuntimeError(
            "Set GOOGLE_APPLICATION_CREDENTIALS to the existing service-account JSON path."
        )
    try:
        import google.auth
        from googleapiclient.discovery import build
    except ImportError as error:
        raise RuntimeError(
            "Missing Python dependencies. Install google-auth and google-api-python-client "
            "in your local environment; do not put credentials in the repository."
        ) from error

    credentials, _ = google.auth.default(scopes=[SCOPE])
    return build("androidpublisher", "v3", credentials=credentials, cache_discovery=False)


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
            service.edits().delete(packageName=package_name, editId=edit_id).execute()


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


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as artifact:
        for chunk in iter(lambda: artifact.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def upload_closed_aab(
    service: Any,
    config: dict[str, Any],
    artifact: Path,
    version_code: str,
    release_name: str,
    release_notes: str | None,
) -> dict[str, Any]:
    """Upload a bundle to the configured Closed Alpha track in one edit."""
    package_name = config["packageName"]
    closed_track = config["tracks"]["closed"]
    if closed_track.get("apiKey") is not None or not closed_track.get("resolveFromApi"):
        raise RuntimeError("Closed track must be resolved from a fresh API track list.")
    if not artifact.is_file() or artifact.suffix.lower() != ".aab":
        raise RuntimeError("Provide an existing .aab bundle.")
    if not version_code.isdigit() or int(version_code) <= 0:
        raise RuntimeError("Version code must be a positive integer.")

    current_version = config.get("versionSource")
    if current_version == "pubspec.yaml":
        pubspec = Path(__file__).resolve().parents[3] / "pubspec.yaml"
        version_line = next(
            (line.removeprefix("version:").strip() for line in pubspec.read_text().splitlines()
             if line.startswith("version:")),
            "",
        )
        configured_code = version_line.rsplit("+", 1)[-1]
        if configured_code != version_code:
            raise RuntimeError(
                f"Requested version code {version_code} does not match pubspec.yaml ({configured_code})."
            )

    edit_id: str | None = None
    try:
        edit_id = service.edits().insert(packageName=package_name, body={}).execute()["id"]
        tracks = service.edits().tracks().list(
            packageName=package_name, editId=edit_id
        ).execute().get("tracks", [])
        used_codes = {
            str(code)
            for track in tracks
            for release in track.get("releases", [])
            for code in release.get("versionCodes", [])
        }
        if version_code in used_codes:
            raise RuntimeError(f"Version code {version_code} already exists on a Play track.")

        api_track = next(
            (track.get("track") for track in tracks
             if track.get("track") == "alpha"),
            None,
        )
        if not api_track:
            raise RuntimeError("Could not resolve the configured Closed Alpha API track.")

        from googleapiclient.http import MediaFileUpload

        upload_request = service.edits().bundles().upload(
            packageName=package_name,
            editId=edit_id,
            media_body=MediaFileUpload(str(artifact), mimetype="application/octet-stream", resumable=True),
        )
        uploaded = None
        while uploaded is None:
            progress, uploaded = upload_request.next_chunk()
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
        committed = service.edits().commit(
            packageName=package_name, editId=edit_id
        ).execute()
        edit_id = None
        return {
            "track": api_track,
            "versionCode": version_code,
            "releaseName": release_name,
            "artifact": str(artifact),
            "sha256": sha256_file(artifact),
            "commit": committed,
        }
    finally:
        if edit_id is not None:
            service.edits().delete(packageName=package_name, editId=edit_id).execute()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("status", "verify-access", "upload-closed"))
    parser.add_argument("--aab", type=Path, help="Signed AAB to upload to Closed Alpha.")
    parser.add_argument("--version-code", help="Expected Play version code; must match pubspec and the AAB.")
    parser.add_argument("--release-name", help="Play release label (for example 1.0.0 (8)).")
    parser.add_argument("--release-notes", help="Optional release notes in the configured default locale.")
    args = parser.parse_args()

    if args.command == "upload-closed" and (not args.aab or not args.version_code or not args.release_name):
        parser.error("upload-closed requires --aab, --version-code and --release-name")
    if args.command != "upload-closed" and any(
        (args.aab, args.version_code, args.release_name, args.release_notes)
    ):
        parser.error("upload options are only valid with upload-closed")

    try:
        config = load_config()
        service = build_service()
        if args.command == "upload-closed":
            result = upload_closed_aab(
                service, config, args.aab, args.version_code,
                args.release_name, args.release_notes,
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
        print(
            f"Google Play {args.command} failed ({type(error).__name__}). "
            "See the publishing runbook for safe recovery; inspect detailed errors locally.",
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
