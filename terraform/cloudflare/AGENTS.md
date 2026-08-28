# Cloudflare Stack Guidance

Read `README.md` in this directory before changing the stack. It documents the
credentials, external source checkout, and deployment sequence.

## Current Scope

- This stack manages the R2-backed private container registry: its R2 bucket,
  Worker script, bindings, and `workers.dev` subdomain.
- It does not currently manage Cloudflare DNS, proxied web records, or a
  Cloudflare Tunnel.
- Application manifests and GitHub workflows consume the registry endpoint, so
  names and authentication changes have repository-wide consequences.

## External Build Contract

- Worker source lives in a sibling checkout of
  `cloudflare/serverless-registry`, not in this repository.
- `build-r2-registry.sh` builds the bundle expected by `registry.tf`.
- `build-r2-registry.sh` honors `SERVERLESS_REGISTRY_DIR`, but `registry.tf`
  currently reads a hard-coded sibling path. Do not rely on the override for a
  plan or apply unless the Terraform bundle path is updated in the same change;
  otherwise Terraform can read a missing or stale default bundle.
- Terraform validation or planning may fail until the expected bundle exists
  because the configuration hashes that file.
- Nested Git worktrees change the relative path from this stack to the external
  checkout. Confirm the exact bundle consumed by Terraform before planning.

Use this order for deployable changes:

```text
build worker bundle -> review Terraform plan -> authorized Terraform apply
```

Do not use `wrangler deploy` for production. Terraform owns the deployed script
content and would revert an imperative deployment on the next apply.

## Conventions

- Put each new Cloudflare concern in `<concern>.tf` with a matching
  `<concern>.variables.tf` and build script when needed.
- Keep credentials in ignored variable files or environment variables.
- Treat the bucket name, Worker script name, subdomain, bindings,
  compatibility date, and authentication contract as externally consumed.
- Do not apply changes without explicit authorization and a reviewed plan.
