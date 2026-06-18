#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANVAS_DIR="${CANVAS_DIR:-$HOME/canvas-lms}"
if [ ! -d "$CANVAS_DIR" ]; then
  git clone https://github.com/instructure/canvas-lms.git "$CANVAS_DIR"
fi
cp "$REPO_ROOT/overrides/docker-compose.override.yml" "$CANVAS_DIR/docker-compose.override.yml"
cd "$CANVAS_DIR"
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
if [ ! -f .setup-complete ]; then
  ./script/docker_dev_setup.sh
  touch .setup-complete
fi
docker compose up -d
echo "Canvas should be available on port 80"
