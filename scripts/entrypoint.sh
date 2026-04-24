#!/bin/sh
set -eu

CRON_SCHEDULE="${CRON_SCHEDULE:-17 3 * * *}"
SYNC_LIMIT="${SYNC_LIMIT:-200}"
INCLUDE_BORDERLINE="${INCLUDE_BORDERLINE:-false}"
RUN_ON_START="${RUN_ON_START:-false}"
LOG_PATH="/var/log/dj-sync/cron.log"

mkdir -p /runtime/.secrets /runtime/.data /runtime/library /var/log/dj-sync
touch "$LOG_PATH"

if [ ! -f /runtime/.env ]; then
  echo "Missing /runtime/.env bind mount. Attach your working DJ-Sync config before starting the container." >&2
fi

EXTRA_ARGS=""
if [ "$INCLUDE_BORDERLINE" = "true" ]; then
  EXTRA_ARGS="--include-borderline"
fi

cat >/etc/cron.d/dj-sync <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$CRON_SCHEDULE root /usr/local/bin/dj-sync-run sync --limit $SYNC_LIMIT $EXTRA_ARGS >> $LOG_PATH 2>&1
EOF

chmod 0644 /etc/cron.d/dj-sync

echo "Installed cron schedule: $CRON_SCHEDULE"

if [ "$RUN_ON_START" = "true" ]; then
  /usr/local/bin/dj-sync-run sync --limit "$SYNC_LIMIT" $EXTRA_ARGS >>"$LOG_PATH" 2>&1 || true
fi

cron
exec tail -F "$LOG_PATH"
