#!/bin/sh
set -eu

cd /runtime
exec ytm-dropbox-dj-sync "$@"

