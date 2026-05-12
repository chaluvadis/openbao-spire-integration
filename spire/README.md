# SPIRE Helm Chart

This chart deploys SPIRE server and agent on Kubernetes.

## Prerequisites

- Kubernetes >= 1.24
- Helm 3+
- PostgreSQL for SPIRE server datastore

## Install

```bash
helm install spire ./spire -n spire --create-namespace
```

## Production hardening highlights

- Standard Helm labels and helper-based naming
- Server/agent configurable service account creation/name
- Configurable pod and container security contexts
- Server probes and optional agent probes
- Server PodDisruptionBudget support
- NetworkPolicy support
- Config checksum annotations for safe rollouts
- Scheduling knobs for production placement and HA

## Database secret handling

Avoid plaintext passwords in values. Prefer existing Secret references:

```yaml
storage:
  postgres:
    host: postgres.default.svc.cluster.local
    port: 5432
    db: spire
    user: spire
    sslmode: require
    existingSecret:
      name: spire-postgres
      key: password
```

Create the secret:

```bash
kubectl -n spire create secret generic spire-postgres \
  --from-literal=password='<strong-password>'
```

## Key values

- `nameOverride`, `fullnameOverride`
- `commonLabels`, `commonAnnotations`
- `server.*` (image, replicas, probes, resources, PDB, service account)
- `agent.*` (image, resources, security context, service account)
- `nodeSelector`, `tolerations`, `affinity`, `topologySpreadConstraints`
- `networkPolicy.*`

## Upgrade guidance

- Use `helm upgrade` with reviewed values files.
- Avoid force upgrades unless explicitly required after impact analysis.
- ConfigMap changes trigger rollouts through checksum annotations.

## Verify

```bash
kubectl get pods -n spire
kubectl get svc -n spire
```

## Uninstall

```bash
helm uninstall spire -n spire
```
