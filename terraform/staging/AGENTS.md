# Hetzner Stack Guidance

This Terraform root stack owns replacement-sensitive infrastructure for the
live K3s cluster.

## Ownership And Invariants

- Hetzner private network: `10.0.0.0/16`.
- Control subnet: `10.0.1.0/24` in the `us-east` network zone.
- Master node private address: `10.0.1.1`.
- Master location: Ashburn (`ash`).
- The master currently has a public IPv4 address and no public IPv6 address.
- K3s installation and host configuration come from the `cloud-init` module.
- Worker-node resources are currently commented out and are not managed.

Coordinate changes to network addresses, interface assumptions, and API
endpoints with the root and stack-local kubeconfig templates and cloud-init
configuration.

## Replacement And Bootstrap Risk

- Server image, location, network attachment, and `user_data` changes can force
  replacement or fail to reconfigure an existing server as expected.
- cloud-init is primarily a first-boot mechanism. A successful plan does not
  mean a template change will be safely applied to an existing node.
- Review changes to `master-cloud-init.yaml` as cluster bootstrap changes, not
  ordinary application configuration.
- Follow the inherited `terraform/AGENTS.md` rules for sensitive cloud-init
  templates and the external-cloud-provider configuration.

## Workflow

Use formatting, backend-disabled initialization, validation, and a reviewed
plan. Never apply, destroy, import, taint, or manipulate state without explicit
authorization. Call out any proposed replacement of the master, network, or
subnet before proceeding.
