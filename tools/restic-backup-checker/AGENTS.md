# Restic Backup Checker Guidance

This directory is an independent Nix build unit that produces the container
used by the cluster's restic-backup-checker CronJob.

## Runtime Contract

- `check-backup.sh` asks restic for the latest snapshot and requires its output
  to contain today's UTC date.
- A restic error or missing current-day snapshot sends a Telegram notification
  and exits nonzero.
- Runtime credentials and repository settings come from the SOPS-encrypted
  Secret under `apps/staging/restic-backup-checker`.
- Do not execute the script with production credentials during validation; it
  can query the backup repository and send real notifications.

## Build And Validation

Use narrow checks first:

```bash
bash -n check-backup.sh
nix build .#docker
```

- `flake.nix` builds the script and its restic, curl, shell, certificate, and
  core utility dependencies into a Docker image.
- `flake.lock` changes only through an intentional Nix dependency update.
- `result` is a generated, ignored Nix output symlink.

## Deployment Coupling

- Changes under this directory trigger
  `.github/workflows/build-restic-backup-checker.yaml` on `main`.
- The workflow pushes the image and dispatches the deployment workflow.
- The deployment workflow updates the image in
  `apps/staging/restic-backup-checker/cronjob.yaml` and commits it to `main`.
- Coordinate entrypoint, executable name, environment variable, or runtime
  behavior changes with the CronJob and encrypted Secret.
