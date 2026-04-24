#!/bin/sh
set -eu

required_vars="
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REFRESH_TOKEN
DROPBOX_APP_KEY
DROPBOX_APP_SECRET
DROPBOX_REFRESH_TOKEN
"

missing=""
for name in $required_vars; do
  eval "value=\${$name:-}"
  if [ -z "$value" ]; then
    missing="$missing $name"
  fi
done

if [ -n "$missing" ]; then
  echo "Missing required Railway variables:$missing" >&2
  exit 1
fi

mkdir -p /tmp/dj-sync/.data /tmp/dj-sync/.secrets /tmp/dj-sync/library /tmp/dj-sync/.tmp
cd /tmp/dj-sync

if [ "${INCLUDE_BORDERLINE:-false}" = "true" ]; then
  exec ytm-dropbox-dj-sync sync --limit "${SYNC_LIMIT:-200}" --include-borderline
fi

exec ytm-dropbox-dj-sync sync --limit "${SYNC_LIMIT:-200}"
