FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends cron ffmpeg ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "git+https://github.com/life-efficient/DJ-Sync.git"

WORKDIR /app

COPY scripts/entrypoint.sh /usr/local/bin/dj-sync-entrypoint
COPY scripts/run-sync.sh /usr/local/bin/dj-sync-run

RUN chmod +x /usr/local/bin/dj-sync-entrypoint /usr/local/bin/dj-sync-run \
    && mkdir -p /runtime /var/log/dj-sync

ENTRYPOINT ["/usr/local/bin/dj-sync-entrypoint"]
