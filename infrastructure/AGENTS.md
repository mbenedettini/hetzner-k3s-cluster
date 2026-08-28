# Shared Infrastructure Guidance

This directory contains cluster-wide components. Changes can affect every
application and must remain declarative through Flux.

## Layering

- `controllers/` installs operators and their CRDs.
- `configs/` contains resources that require those controllers, currently the
  cert-manager ClusterIssuer and Istio IngressClass.
- `addons/` contains shared runtime infrastructure, currently Istio.
- Put cluster-specific values and patches under `clusters/staging` rather than
  making reusable resources environment-specific.

The intended controller relationships include:

```text
cert-manager -> ClusterIssuer -> Certificate
istio-base -> istiod -> istio-ingress
```

Only some relationships are encoded by Flux or Helm `dependsOn`. Check the
actual manifests before relying on reconciliation order. In particular,
`infra-addons` does not currently declare a Flux dependency on controllers or
configs, and the Istio Helm releases share a Kustomization with resources that
use their CRDs.

## Ingress Invariants

- The Istio ingress Helm release owns the `LoadBalancer` Service on ports 80 and
  443 and its Hetzner load-balancer annotations.
- The shared Gateway accepts the production hostnames and terminates TLS with
  `k3s-ingress-cert-0`.
- The Certificate DNS names, Gateway hosts, and application VirtualService
  hosts must be changed together.
- cert-manager currently obtains the ingress certificate through an Istio
  HTTP-01 solver.
- Application routing lives under `apps/staging`, not in the ingress gateway
  Helm release.

## Operational Boundaries

- Do not perform live Helm upgrades or imperative Istio/cert-manager changes as
  a substitute for editing these resources.
- `hccm-values.yaml` at the repository root is not referenced by a Flux or Helm
  resource. The Hetzner Cloud Controller Manager installation is not declared
  in this repository, so do not assume that file is reconciled.
- Preserve the Helm API versions and release dependency chain when upgrading
  charts.

Render each affected Kustomization and run `./scripts/validate.sh` after shared
infrastructure changes.
