#!/bin/sh
set -eu

/usr/local/bin/dj-sync-update || true

cd /runtime
exec ytm-dropbox-dj-sync "$@"
