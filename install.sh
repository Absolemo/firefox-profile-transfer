#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOST_NAME="org.absolem.firefox_profile_transfer"
EXTENSION_ID="profile-tab-transfer@absolem.local"

HOST_DIR="$HOME/.local/share/firefox-profile-transfer"
NATIVE_DIR="$HOME/.mozilla/native-messaging-hosts"

HOST_SCRIPT="$HOST_DIR/transfer.py"
HOST_MANIFEST="$NATIVE_DIR/$HOST_NAME.json"

echo "Installing Firefox Profile Tab Transfer..."

mkdir -p "$HOST_DIR"
mkdir -p "$NATIVE_DIR"

cp "$PROJECT_DIR/native-host/transfer.py" "$HOST_SCRIPT"
chmod 755 "$HOST_SCRIPT"

python3 - "$HOST_SCRIPT" "$HOST_MANIFEST" "$EXTENSION_ID" <<'PY'
import json
import sys

host_script, manifest_path, extension_id = sys.argv[1:]

manifest = {
    "name": "org.absolem.firefox_profile_transfer",
    "description": "Firefox Profile Tab Transfer",
    "path": host_script,
    "type": "stdio",
    "allowed_extensions": [extension_id]
}

with open(manifest_path, "w") as file:
    json.dump(manifest, file, indent=2)
    file.write("\n")
PY

chmod 644 "$HOST_MANIFEST"

echo ""
echo "Installation completed successfully!"
echo "Native host: $HOST_SCRIPT"
echo "Manifest:    $HOST_MANIFEST"
