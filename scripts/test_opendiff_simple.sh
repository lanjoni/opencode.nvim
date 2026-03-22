#!/bin/bash

# Simple openDiff test using websocat (if available) or curl
# Note: This script tests the legacy WebSocket/MCP protocol which is WIP for OpenCode.
# OpenCode currently uses terminal-based integration instead.

set -e

echo "🧪 Testing openDiff tool behavior..."

# Find the port from lock file
LOCK_DIR="$HOME/.opencode/ide"
if [[ ! -d $LOCK_DIR ]]; then
  echo "❌ Lock directory not found: $LOCK_DIR"
  echo "   Make sure Neovim with opencode.nvim is running"
  exit 1
fi

LOCK_FILE=$(find "$LOCK_DIR" -name "*.lock" -type f 2>/dev/null | head -1)
if [[ -z $LOCK_FILE ]]; then
  echo "❌ No lock files found in $LOCK_DIR"
  echo "   Make sure Neovim with opencode.nvim is running"
  exit 1
fi

PORT=$(basename "$LOCK_FILE" .lock)
echo "✅ Found port: $PORT"

# Read README.md
if [[ ! -f "README.md" ]]; then
  echo "❌ README.md not found - run this script from project root"
  exit 1
fi

echo "✅ Found README.md"

# Create modified content (add license section)
NEW_CONTENT=$(cat README.md && echo -e "\n## License\n\n[MIT](LICENSE)")

# Get absolute path
ABS_PATH="$(pwd)/README.md"

# Create JSON-RPC message
JSON_MESSAGE=$(
  cat <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "openDiff",
    "arguments": {
      "old_file_path": "$ABS_PATH",
      "new_file_path": "$ABS_PATH",
      "new_file_contents": $(echo "$NEW_CONTENT" | jq -Rs .),
      "tab_name": "✻ [Test] README.md (automated) ⧉"
    }
  }
}
EOF
)

echo "📤 Sending openDiff tool call to ws://127.0.0.1:$PORT"

# Try different WebSocket clients
if command -v websocat >/dev/null 2>&1; then
  echo "Using websocat..."
  echo "$JSON_MESSAGE" | timeout 30s websocat "ws://127.0.0.1:$PORT" || {
    if [[ $? -eq 124 ]]; then
      echo "✅ Tool blocked for 30s (good behavior!)"
      echo "👉 Check Neovim for the diff view"
    else
      echo "❌ Connection failed"
    fi
  }
elif command -v wscat >/dev/null 2>&1; then
  echo "Using wscat..."
  echo "$JSON_MESSAGE" | timeout 30s wscat -c "ws://127.0.0.1:$PORT" || {
    if [[ $? -eq 124 ]]; then
      echo "✅ Tool blocked for 30s (good behavior!)"
      echo "👉 Check Neovim for the diff view"
    else
      echo "❌ Connection failed"
    fi
  }
else
  echo "❌ No WebSocket client found (websocat or wscat needed)"
  echo "   Install with: brew install websocat"
  echo "   Or: npm install -g wscat"
  exit 1
fi

echo "✅ Test completed"
