#!/usr/bin/env python3
"""Read Google Play track state through a temporary Android Publisher edit."""

from __future__ import annotations

import argparse
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


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("status", "verify-access"))
    args = parser.parse_args()

    try:
        config = load_config()
        service = build_service()
        tracks = with_verification_edit(
            service,
            config["packageName"],
            read_tracks=args.command == "status",
        )
    except Exception as error:  # API/credential exceptions can include private paths or request details
        print(
            f"Google Play {args.command} failed ({type(error).__name__}). "
            "See the publishing runbook for safe recovery; inspect detailed errors locally.",
            file=sys.stderr,
        )
        return 1

    if args.command == "verify-access":
        print(f"Access verified for {config['packageName']}; temporary edit deleted.")
    else:
        print(json.dumps([summarize_track(track) for track in tracks], indent=2))
        print("Temporary read edit deleted. No track or listing changes were made.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
