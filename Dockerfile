FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ARG DJ_SYNC_VERSION=0.2.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends cron ffmpeg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    packaging \
    "https://github.com/life-efficient/DJ-Sync/releases/download/v${DJ_SYNC_VERSION}/ytm_dropbox_dj_sync-${DJ_SYNC_VERSION}-py3-none-any.whl"

WORKDIR /app

COPY scripts/entrypoint.sh /usr/local/bin/dj-sync-entrypoint
COPY scripts/run-sync.sh /usr/local/bin/dj-sync-run
COPY scripts/update-cli.sh /usr/local/bin/dj-sync-update

RUN chmod +x /usr/local/bin/dj-sync-entrypoint /usr/local/bin/dj-sync-run /usr/local/bin/dj-sync-update \
    && mkdir -p /runtime /var/log/dj-sync

ENTRYPOINT ["/usr/local/bin/dj-sync-entrypoint"]
