# Application Guidance

Application resources are reconciled by Flux from `apps/staging`. Follow the
root safety and secret-handling rules in addition to the conventions below.

## Layout And Ownership

- Put reusable definitions under `apps/base` and cluster-specific leaves or
  overlays under `apps/staging`.
- Each application leaf should have an explicit `kustomization.yaml`, Namespace
  resource, and namespace assignment.
- Podinfo is the current base-and-overlay example. Marianobe site, NetBird, and
  restic-backup-checker are cluster-specific leaves.
- Keep chart versions, image references, replica counts, and resource requests
  or limits explicit and intentional.

## Secrets

- Application secret manifests are SOPS-encrypted in place and must never be
  committed decrypted.
- Ensure encrypted runtime and registry Secrets remain listed by the owning
  Kustomization.
- Decrypt a secret only when the explicit task requires it. Do not print or log
  decrypted values. If a local plaintext artifact is unavoidable, use the
  ignored `*-plain.yaml` convention and remove the artifact immediately after
  re-encryption; the ignore rule is only a final safeguard.

## Shared Ingress Contract

- Application `VirtualService` resources reference
  `istio-ingress/istio-gw`.
- Adding or removing a public hostname normally requires coordinated changes to
  the VirtualService, `infrastructure/addons/istio/gateway.yaml` Gateway hosts,
  and the Certificate DNS names in that same file.
- Podinfo depends on a `/podinfo/` to `/` URI rewrite.
- NetBird route order is significant. Preserve its HTTP, gRPC, WebSocket,
  relay, and dashboard fallback behavior when editing routes.

## Deployment Automation

- `.github/workflows/deploy-marianobe-site.yaml` updates the image in
  `apps/staging/marianobe-site/deployment.yaml` and commits to `main`.
- `.github/workflows/deploy-restic-backup-checker.yaml` updates the image in
  `apps/staging/restic-backup-checker/cronjob.yaml` and commits to `main`.
- Treat those image fields as automation-owned pointers. Coordinate path,
  container-order, or YAML-shape changes with the corresponding workflow.
- The restic CronJob runtime contract is also coupled to
  `tools/restic-backup-checker` and its encrypted Secret.

Build the affected Kustomize leaf and run `./scripts/validate.sh` after manifest
changes. Add an application-local `AGENTS.md` only when an application becomes
large enough to have independent build or operational conventions.
