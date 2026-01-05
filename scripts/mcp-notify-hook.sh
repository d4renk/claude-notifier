#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${CLAUDE_NOTIFY_CONFIG:-$ROOT_DIR/config.sh}"
NODE_SCRIPT="${CLAUDE_NOTIFY_NODE_SCRIPT:-$ROOT_DIR/scripts/mcp-notify.js}"

if [[ -f "$CONFIG_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  set +a
fi

if [[ ! -f "$NODE_SCRIPT" ]]; then
  echo "[mcp-notify] Missing node script: $NODE_SCRIPT" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "[mcp-notify] Node.js is required to run $NODE_SCRIPT" >&2
  exit 1
fi

node "$NODE_SCRIPT"
