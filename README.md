# DJ-Sync Container

This repo builds a small Docker container that installs [DJ-Sync](https://github.com/life-efficient/DJ-Sync), then runs it from a traditional cron job.

## How It Works

- the image installs the latest `DJ-Sync` CLI from GitHub
- the container does not bake in secrets
- instead, it bind-mounts your working DJ-Sync runtime files from the host
- cron runs `ytm-dropbox-dj-sync sync --limit 200` on a daily schedule

## Secret Onboarding

The cleanest onboarding flow is to reuse the working runtime from your existing `DJ-Sync` checkout instead of copying secrets into the image.

This container expects these host paths:

- `.env`
- `.secrets/`
- `.data/`
- `library/`

By default, `compose.yaml` looks for them in `../ytm-dropbox-dj-sync`, so if this repo sits next to your working `DJ-Sync` checkout, no extra setup is needed.

If your working checkout lives somewhere else, set `DJ_SYNC_SOURCE_DIR` in a local `.env` file before starting the container.

## Setup

1. Create a local `.env` from [`.env.example`](/Users/harryberg/projects/DJ-Sync-Container/.env.example):

```bash
cp .env.example .env
```

2. Adjust values if needed:

- `DJ_SYNC_SOURCE_DIR`: path to your working `DJ-Sync` checkout
- `CRON_SCHEDULE`: standard cron expression
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
- Rebuild the image when you want to pick up new `DJ-Sync` commits from GitHub.
- The runtime data remains on the host because the container bind-mounts your working config, auth, and library directories.
