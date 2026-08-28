# GitHub Actions Guidance

These workflows validate configuration, publish images, and mutate GitOps image
references. Changes to triggers, permissions, credentials, and target paths are
security- and production-sensitive.

## Workflow Map

- `flux-checks.yaml` runs `scripts/validate.sh` for pull requests and branch
  pushes.
- `terraform-checks.yaml` formats Terraform but currently runs `init` and
  `validate` from the repository root instead of either real stack.
- `build-restic-backup-checker.yaml` builds and pushes the Nix image, then emits
  a repository dispatch.
- `deploy-marianobe-site.yaml` and `deploy-restic-backup-checker.yaml` have
  `contents: write`, update a manifest, commit, and push directly to `main`.

## External Contracts

- Preserve repository-dispatch event names and client payload shapes unless all
  producers and consumers are updated together.
- Both deployment workflows accept a source commit SHA from either
  `repository_dispatch` or `workflow_dispatch`, validate it, and normalize it
  to the eight-character image tag published by their build workflows.
- Preserve required GitHub variable and secret names unless the repository
  configuration is migrated at the same time.
- The Marianobe deployment workflow edits
  `apps/staging/marianobe-site/deployment.yaml`.
- The restic deployment workflow edits
  `apps/staging/restic-backup-checker/cronjob.yaml`.
- YAML path and container-order changes in those manifests require matching
  workflow changes.
- Registry host and image names are consumed by workflows and application
  manifests.

## Safe Changes

- Do not dispatch deployment or image-publication workflows merely to test
  workflow syntax.
- Review every change to `permissions`, tokens, write operations, branch names,
  triggers, target paths, and third-party action versions.
- Do not interpolate GitHub expressions directly into shell scripts. Pass event
  data through an environment variable, quote it in the shell, and validate its
  expected format before using it in a command. Deployment source SHAs must be
  validated as hexadecimal commit identifiers. Restic SHAs must resolve in this
  repository; the Marianobe SHA comes from an external repository and need not
  exist in this checkout.
- Pin new or updated third-party actions to a full commit SHA, especially in
  workflows with registry credentials, write tokens, or `contents: write`. Do
  not introduce mutable references such as `@main`.
- Avoid exposing event payloads or secrets in logs.
- Validate workflow YAML and use `git diff --check`; use a non-production test
  path when behavior must be exercised.
