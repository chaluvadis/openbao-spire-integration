# OpenBao Helm Chart

This chart deploys OpenBao on Kubernetes using a StatefulSet with Raft storage.

## Prerequisites

- Kubernetes >= 1.24
- Helm 3+
- StorageClass for PVCs

## Install

```bash
kubectl create namespace dev-security
helm install openbao ./openbao -n dev-security
```

## Production hardening highlights

- Standard Helm labels and helper-based naming
- Configurable service account creation/name and token automount behavior
- Configurable pod and container security contexts
- Startup/readiness/liveness probes
- PodDisruptionBudget support
- NetworkPolicy support
- Config checksum annotations for safe rollouts
- Scheduling knobs: affinity, tolerations, nodeSelector, topologySpreadConstraints

## TLS configuration

TLS is modeled through values and a Secret reference.

```yaml
# values.yaml
tls:
  enabled: true
  secretName: openbao-server-tls
  certFile: tls.crt
  keyFile: tls.key
  caFile: ca.crt
```

Create the Secret before install/upgrade:

```bash
kubectl -n dev-security create secret generic openbao-server-tls \
  --from-file=tls.crt=server.crt \
  --from-file=tls.key=server.key \
  --from-file=ca.crt=ca.crt
```

## Key values

- `nameOverride`, `fullnameOverride`
- `commonLabels`, `commonAnnotations`, `podAnnotations`
- `service.type`, `service.port`, `service.clusterPort`
- `serviceAccount.create`, `serviceAccount.name`, `serviceAccount.automountServiceAccountToken`
- `resources`
- `nodeSelector`, `tolerations`, `affinity`, `topologySpreadConstraints`
- `podSecurityContext`, `containerSecurityContext`
- `podDisruptionBudget.*`
- `networkPolicy.*`

## Upgrade guidance

- Use standard upgrades (`helm upgrade`) and review values changes before rollout.
- Config changes in `ConfigMap` trigger StatefulSet rollouts via checksum annotations.
- For major version upgrades, test in a staging environment first.

## Uninstall

```bash
helm uninstall openbao -n dev-security
```

If needed, remove namespace separately:

```bash
kubectl delete namespace dev-security
```
