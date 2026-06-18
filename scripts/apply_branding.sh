#!/usr/bin/env bash
set -euo pipefail

CANVAS_CONTAINER="${CANVAS_CONTAINER:-canvas-lms-web-1}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

docker cp "$SCRIPT_DIR/apply_branding.rb" "$CANVAS_CONTAINER:/tmp/apply_branding.rb"
docker exec "$CANVAS_CONTAINER" bundle exec rails runner /tmp/apply_branding.rb

echo "Branding applied. Open Canvas in your browser (default http://localhost:8080)."
