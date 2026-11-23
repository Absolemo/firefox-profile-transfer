#!/usr/bin/env bash
set -euo pipefail

HOST_NAME="org.absolem.firefox_profile_transfer"

HOST_DIR="$HOME/.local/share/firefox-profile-transfer"
HOST_MANIFEST="$HOME/.mozilla/native-messaging-hosts/$HOST_NAME.json"

echo "Uninstalling Firefox Profile Tab Transfer..."

rm -f "$HOST_MANIFEST"
rm -rf "$HOST_DIR"

echo "Native messaging host removed."
echo "You can now remove the Firefox extension separately."
