# K3s cluster on Hetzner Cloud using Terraform + FluxCD

![Terraform checks](https://github.com/mbenedettini/hetzner-k3s-cluster/actions/workflows/terraform-checks.yaml/badge.svg)

![Flux checks](https://github.com/mbenedettini/hetzner-k3s-cluster/actions/workflows/flux-checks.yaml/badge.svg)

## Description

This project aims to show how an unexpensive kubernetes cluster can be set up in a cloud provider such as [Hetzner](https://www.hetzner.com/cloud/).

The cluster runs on 2cpu/2gb nodes that cost about $5 monthly on their Virginia based datacenter and also includes a [load balancer](https://www.hetzner.com/cloud/load-balancer/) that costs about the same.

I have used Terraform to manage nodes and networking and [FluxCD](https://fluxcd.io/) for continuous delivery. More details below.

## Tech details

I've decided to use [K3S](https://k3s.io/) (instead of kubeadm to set up the cluster) since the idea was for this cluster to be inexpensive and K3S would allow me to get the most out of the VPS nodes.

Terraform manages a private network with a subnet and the master node, under workspace [staging](https://github.com/mbenedettini/hetzner-k3s-cluster/tree/main/terraform/staging) (doesn't mean that it actually is a staging environment just a name for it).

Flux manages Kubernetes resources and apps. My own personal site (https://marianobe.cc/) is hosted [here](https://github.com/mbenedettini/hetzner-k3s-cluster/tree/main/apps/staging/marianobe-site) and gets deployed using a [Github Action](https://github.com/mbenedettini/hetzner-k3s-cluster/blob/main/.github/workflows/deploy-marianobe-site.yaml) triggered from its own repository. 

The public ip address you see of my site is a Load Balancer provided by Hetzner that was automatically set up as part of the [Istio](https://istio.io/) [Ingress infra](https://github.com/mbenedettini/hetzner-k3s-cluster/tree/main/infrastructure/addons/istio). 

Certificates are managed by [Cert-Manager](https://cert-manager.io/) and using Letsencrypt.

All in all not bad for a whole cluster running on 2gb, although things look a bit tight and I'll be adding worker nodes + autoscaler shortly:

![image](https://github.com/user-attachments/assets/4caef685-84fb-42ec-9179-c4f3a0f55edf)


## Connecting to the cluster

Open an SSH Socks proxy to the master node and use kubectl:

```
$ ssh -D 6443 cluster@<master node public ip>
# (kubectl config already set by direnv)
$ kubectl get nodes
NAME          STATUS   ROLES                  AGE     VERSION
master-node   Ready    control-plane,master   6m49s   v1.30.5+k3s1
```

Alternatively use an app such as
[Secure Pipes](https://www.opoet.com/pyro/index.php) or
[autossh](https://github.com/autossh/autossh) to keep the proxy connection open.

## TODO

1) Add more (worker) nodes + autoscaler. Worker nodes templates would be defined by Terraform with count = 0 and Autoscaler should decide how many are needed.
2) Add an Airbyte or Dagster pipeline to show how these workflows can be implemented and scale using inexpensive computing power.
