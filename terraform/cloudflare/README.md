# Cloudflare resources

Terraform stack for Cloudflare resources. Currently manages the R2-backed
container registry at
[r2-registry-production.mbenedettini-cloudflare.workers.dev](https://r2-registry-production.mbenedettini-cloudflare.workers.dev).

## Layout

| File                    | Purpose                                                        |
| ----------------------- | -------------------------------------------------------------- |
| `main.tf`               | cloudflare provider + S3 (R2) state backend                    |
| `variables.tf`          | shared variables (Cloudflare account ID)                       |
| `registry.tf`           | the container registry: R2 bucket + worker script + workers.dev |
| `registry.variables.tf`  | registry-specific variables (basic auth credentials)           |
| `build-r2-registry.sh`  | builds the registry worker bundle from the sibling repo        |
| `secrets.auto.tfvars`   | gitignored; holds account ID + registry credentials            |

When adding new Cloudflare resources, create one `<concern>.tf` file (plus
`<concern>.variables.tf` and `build-<name>.sh` when needed) instead of
extending `registry.tf`.

## Setup

1. Create a Cloudflare API token with these permissions:
   - Account / Workers Scripts: Read + Write
   - Account / Workers Tail: Read
   - Account / Account R2 Storage: Read + Write
2. Add it to `.envrc-secrets` at the repo root (see `.envrc-secrets.template`)
   as `CLOUDFLARE_API_TOKEN` and run `direnv allow`.
3. Fill in `secrets.auto.tfvars`:

   ```hcl
   cloudflare_account_id = "<account id>"
   registry_username     = "<registry username>"
   registry_password     = "<registry password>"
   ```

## Deploying

The worker source is **not** in this repo. It lives in a sibling clone of
[cloudflare/serverless-registry](https://github.com/cloudflare/serverless-registry)
(expected at `../../../serverless-registry` relative to this directory — a
clone next to `hetzner-k3s-cluster`; override with the `SERVERLESS_REGISTRY_DIR`
env var).

```bash
# 1. Build the worker bundle (runs wrangler in the sibling repo)
./build-r2-registry.sh

# 2. Apply
terraform init
terraform plan
terraform apply
```

`terraform plan`/`apply` fail if the bundle hasn't been built.

**Do not deploy the production worker with `wrangler deploy` anymore** —
Terraform owns the script content now and would revert manual deploys on the
next apply. Local development with `wrangler dev` is unaffected.

## Updating the registry code

To incorporate upstream changes from Cloudflare's repo:

```bash
git -C ../../../serverless-registry pull
./build-r2-registry.sh
terraform plan   # shows a content update on the worker script
terraform apply
```
