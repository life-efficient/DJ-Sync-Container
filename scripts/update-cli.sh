#!/bin/sh
set -eu

if [ "${DJ_SYNC_AUTO_UPDATE:-false}" != "true" ]; then
  exit 0
fi

STAMP_DIR="/runtime/.data"
STAMP_FILE="$STAMP_DIR/last-update-check.txt"
TODAY="$(date -u +%F)"

mkdir -p "$STAMP_DIR"

if [ -f "$STAMP_FILE" ] && [ "$(cat "$STAMP_FILE")" = "$TODAY" ]; then
  exit 0
fi

CURRENT_VERSION="$(python - <<'PY'
from importlib.metadata import version
print(version("ytm-dropbox-dj-sync"))
PY
)"

LATEST_VERSION="$(python - <<'PY'
import json
import urllib.request

with urllib.request.urlopen("https://pypi.org/pypi/ytm-dropbox-dj-sync/json", timeout=10) as response:
    payload = json.load(response)

print(payload["info"]["version"])
PY
)"

if python - "$CURRENT_VERSION" "$LATEST_VERSION" <<'PY'
import sys
from packaging.version import Version

current = Version(sys.argv[1])
latest = Version(sys.argv[2])
sys.exit(0 if latest > current else 1)
PY
then
  echo "Updating DJ-Sync from $CURRENT_VERSION to $LATEST_VERSION"
  python -m pip install --no-cache-dir --upgrade "ytm-dropbox-dj-sync==$LATEST_VERSION"
else
  echo "DJ-Sync is already current at $CURRENT_VERSION"
fi

printf '%s' "$TODAY" >"$STAMP_FILE"
