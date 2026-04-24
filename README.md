# DJ-Sync Container

This repo builds a small Docker container that installs [DJ-Sync](https://github.com/life-efficient/DJ-Sync), then runs it from a traditional cron job.

## How It Works

- the image installs a pinned `DJ-Sync` package release
- the container does not bake in secrets
- instead, it bind-mounts your working DJ-Sync runtime files from the host
- cron runs `ytm-dropbox-dj-sync sync --limit 200` on a daily schedule
- optional auto-update checks can upgrade the installed CLI from PyPI once per day before a sync runs

## Secret Onboarding

The cleanest onboarding flow is to reuse the working runtime from your existing `DJ-Sync` checkout instead of copying secrets into the image.

This container expects these host paths:

- `.env`
- `.secrets/`
- `.data/`
- `library/`

By default, `compose.yaml` looks for them in `../ytm-dropbox-dj-sync`, so if this repo sits next to your working `DJ-Sync` checkout, no extra setup is needed.

If your working checkout lives somewhere else, set `DJ_SYNC_SOURCE_DIR` in a local `.env` file before starting the container.

## Version Pinning

The local Docker setup installs a pinned release asset from GitHub.

Set `DJ_SYNC_VERSION` in your local `.env` if you want to upgrade or roll back the installed CLI version.

If you set `DJ_SYNC_AUTO_UPDATE=true`, the container will check PyPI once per UTC day before running a sync. If a newer `ytm-dropbox-dj-sync` release exists, it upgrades the CLI in-place and then runs the job.

## Setup

1. Create a local `.env` from [`.env.example`](/Users/harryberg/projects/DJ-Sync-Container/.env.example):

```bash
cp .env.example .env
```

2. Adjust values if needed:

- `DJ_SYNC_SOURCE_DIR`: path to your working `DJ-Sync` checkout
- `CRON_SCHEDULE`: standard cron expression
- `DJ_SYNC_VERSION`: released DJ-Sync package version
- `DJ_SYNC_AUTO_UPDATE`: set to `true` if you want the container to pick up newer PyPI releases automatically
- `SYNC_LIMIT`: how many liked items to inspect per run
- `INCLUDE_BORDERLINE`: set to `true` only if you want looser matching
- `RUN_ON_START`: set to `true` if you want one sync immediately when the container starts

3. Build and start the container:

```bash
docker compose up -d --build
```

4. View logs:

```bash
docker logs -f dj-sync-cron
```

## Notes

- This repo does not prune Docker volumes or clean up unrelated containers.
- Rebuild the image when you want to pick up a new pinned base version.
- If `DJ_SYNC_AUTO_UPDATE=true`, routine package upgrades happen inside the running container without a rebuild.
- If you recreate the container from scratch, it starts again from the image's pinned base version and can then auto-update forward from there.
- The runtime data remains on the host because the container bind-mounts your working config, auth, and library directories.

## Railway

Railway has a native cron-job deployment model, so the better Railway setup is not to run cron inside the container.

This repo includes:

- `Dockerfile.railway`: a one-shot image for Railway
- `railway.toml`: config-as-code for a Railway cron deployment
- `scripts/railway-start.sh`: startup validation for required secrets

Recommended Railway variables:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_REFRESH_TOKEN`
- `DROPBOX_APP_KEY`
- `DROPBOX_APP_SECRET`
- `DROPBOX_REFRESH_TOKEN`
- `DROPBOX_ROOT`
- `SYNC_LIMIT`
- `INCLUDE_BORDERLINE`

Railway variables are the right place for secrets. Railway's config file can define the Dockerfile path, start command, and cron schedule, but it does not itself enforce secret prompts. The startup script fills that gap by failing clearly if required variables are missing.
