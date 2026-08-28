# Repository Guidance

This repository provisions and operates a small K3s cluster on Hetzner Cloud.
Terraform manages cloud resources, cloud-init bootstraps K3s, and Flux reconciles
Kubernetes infrastructure and applications from `main`.

## Repository Map

- `terraform/`: independent Hetzner and Cloudflare Terraform root stacks plus
  shared modules.
- `clusters/staging/`: Flux entry point and cluster-specific patches. Despite
  the name, this is the live cluster rather than a disposable test environment.
- `infrastructure/`: shared controllers, configuration, and add-ons such as
  cert-manager and Istio.
- `apps/`: application bases and cluster-specific workloads.
- `secrets/`: cluster-level SOPS-encrypted manifests.
- `tools/`: independently built operational utilities.
- `.github/workflows/`: validation, image publication, and GitOps deployment
  automation.

Read the nearest nested `AGENTS.md` before changing files in one of these
areas. Nested guidance supplements this file.

## Sources Of Truth

- Make Kubernetes changes in Git. Do not use live `kubectl apply`, Helm
  installs/upgrades, or imperative resource edits as a substitute for GitOps.
- Flux reconciles `main` with pruning enabled. A merge, deletion, or path rename
  can change or remove live resources.
- Do not run `terraform apply`, `terraform destroy`, state commands, live
  `flux reconcile`, or deployment workflow dispatches unless the user
  explicitly requests the live operation.
- Prefer rendering, formatting, static validation, and reviewed Terraform plans.
- Inspect reconciliation and runtime dependencies before renaming or deleting
  resources.

## Secrets And Local State

- Tracked Kubernetes secrets must remain SOPS-encrypted. `.sops.yaml` encrypts
  YAML `data` and `stringData` fields with the configured PGP recipient.
- Never expose or commit decrypted `*-plain.yaml` files, credentials, or a SOPS
  private key. Inspect secret material only when the task explicitly requires a
  secret operation, and never print decrypted values into logs or responses.
- Do not inspect or commit ignored credentials and state, including
  `.envrc-secrets`, `secrets.auto.tfvars`, `keys`, `.terraform/`, Terraform
  state, and `kubeconfig.yaml`, unless the explicit task requires that specific
  local input.
- `direnv allow` is stateful: it loads local credentials and may generate
  `kubeconfig.yaml`. Do not run it merely to inspect the repository.
- Public SOPS recipient material, such as `clusters/staging/.sops.pub.asc`, is
  safe to track; private key material is not.

## Generated Files

- Do not hand-edit Flux-generated `gotk-components.yaml` or `gotk-sync.yaml`.
- Change lock files only through their owning tool and only as part of an
  intentional dependency update.
- `.terraform/`, Nix `result` symlinks, and `kubeconfig.yaml` are local outputs.
- Do not treat unrelated local or untracked files as repository conventions.

## Validation

For Kubernetes and Flux changes, run:

```bash
./scripts/validate.sh
```

The script requires `yq`, `kustomize`, and `kubeconform`; see its header for
the expected versions. It checks YAML syntax, Flux resources, and every
discovered Kustomize tree. Kubernetes Secrets are skipped because SOPS metadata
does not conform to the plain Secret schema, and missing CRD schemas are
ignored.

For other changes, use the narrowest applicable checks:

```bash
bash -n path/to/script.sh
terraform -chdir=terraform/staging fmt -check
terraform -chdir=terraform/staging init -backend=false
terraform -chdir=terraform/staging validate
git diff --check
```

There is no Terraform root module at the repository root. Always select an
actual stack explicitly. Read `README.md` for the operator-facing overview and
connection instructions.
