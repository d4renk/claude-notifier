#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_SCRIPT="$SCRIPT_DIR/mcp-notify.js"

if [[ ! -f "$NODE_SCRIPT" ]]; then
  echo "[mcp-notify] Missing node script: $NODE_SCRIPT" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "[mcp-notify] Node.js is required to run $NODE_SCRIPT" >&2
  exit 1
fi

node "$NODE_SCRIPT"
