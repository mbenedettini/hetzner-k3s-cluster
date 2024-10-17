# K3s cluster on Hetzner Cloud using Terraform + FluxCD

![Terraform checks](https://github.com/mbenedettini/hetzner-k3s-cluster/actions/workflows/terraform-checks.yml/badge.svg)

![Flux checks](https://github.com/mbenedettini/hetzner-k3s-cluster/actions/workflows/flux-checks.yml/badge.svg)


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
