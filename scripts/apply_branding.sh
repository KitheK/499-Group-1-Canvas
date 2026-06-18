#!/usr/bin/env bash
set -euo pipefail

CANVAS_CONTAINER="${CANVAS_CONTAINER:-canvas-lms-web-1}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

docker cp "$REPO_ROOT/assets/course-cards" "$CANVAS_CONTAINER:/tmp/group1-course-cards"
docker cp "$SCRIPT_DIR/apply_branding.rb" "$CANVAS_CONTAINER:/tmp/apply_branding.rb"
docker exec "$CANVAS_CONTAINER" bundle exec rails runner /tmp/apply_branding.rb

echo "Branding applied. Open Canvas in your browser (default http://localhost:8080)."
echo "Run scripts/apply_course_card_images.py to persist card images via the Canvas API."
