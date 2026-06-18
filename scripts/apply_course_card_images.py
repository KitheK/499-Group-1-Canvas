#!/usr/bin/env python3
"""Assign rotating dashboard card images to all account courses."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

_REPO_ROOT = Path(__file__).resolve().parents[1]
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))

from scripts.lib.canvas_client import CanvasClient  # noqa: E402


def load_env_file(env_path: Path) -> None:
    if not env_path.exists():
        return
    for raw_line in env_path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def load_image_names() -> list[str]:
    manifest = _REPO_ROOT / "assets" / "course-cards" / "images.json"
    if manifest.exists():
        return json.loads(manifest.read_text())
    return sorted(path.name for path in (_REPO_ROOT / "assets" / "course-cards").glob("*.png"))


def paginate(client: CanvasClient, path: str, **params):
    page = 1
    while True:
        batch = client.get(path, per_page=100, page=page, **params)
        if not batch:
            break
        yield from batch
        if len(batch) < 100:
            break
        page += 1


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    load_env_file(_REPO_ROOT / ".env")
    base_url = os.getenv("CANVAS_URL", "http://localhost:8080").rstrip("/")
    token = os.getenv("ADMIN_TOKEN", "").strip()
    if not token and not args.dry_run:
        raise SystemExit("Missing ADMIN_TOKEN in environment or .env")

    image_names = load_image_names()
    if not image_names:
        raise SystemExit("No course card images found in assets/course-cards/")

    image_urls = [f"{base_url}/group1/course-cards/{name}" for name in image_names]
    client = None if args.dry_run else CanvasClient(base_url, token)

    courses = []
    if args.dry_run:
        print(f"Dry run — would assign {len(image_urls)} rotating images from {base_url}/group1/course-cards/")
        return

    for course in paginate(client, "/accounts/self/courses"):
        if course.get("workflow_state") in {"deleted", "completed"}:
            continue
        courses.append(course)

    courses.sort(key=lambda c: (c.get("course_code") or "", c.get("name") or "", c.get("id", 0)))

    for index, course in enumerate(courses):
        image_url = image_urls[index % len(image_urls)]
        course_id = course["id"]
        code = course.get("course_code") or course.get("name") or course_id
        client.put(
            f"/courses/{course_id}",
            {"course": {"image_url": image_url}},
        )
        print(f"Set {code} (id={course_id}) -> {Path(image_url).name}")

    print(f"Updated {len(courses)} course(s) with {len(image_urls)} rotating card images.")


if __name__ == "__main__":
    main()
