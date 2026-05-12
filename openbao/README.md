# 📘 OpenBao Helm Chart

This chart deploys **OpenBao** as a high-availability secrets and PKI system on Kubernetes using a StatefulSet with Raft storage.

---

## 🧭 Prerequisites

- Kubernetes cluster (v1.24+)
- Helm 3+
- StorageClass available (for persistent volumes)

---

## 📦 Installation

### Create namespace and install

```bash
kubectl create namespace prod-security

helm install openbao ./openbao \
  -n prod-security \
  -f my-values.yaml
```

### Verify installation

```bash
kubectl get pods -n prod-security
kubectl get svc -n prod-security
```

---

## 🔐 First-time initialization

After installation, OpenBao starts in a **sealed state** and must be initialized once.

### Initialize

```bash
kubectl exec -it openbao-0 -n prod-security -- bao operator init
```

Save the **unseal keys** and **root token** securely (e.g., in a hardware security module or offline vault).

### Unseal each pod

```bash
kubectl exec -it openbao-0 -n prod-security -- bao operator unseal <UNSEAL_KEY_1>
kubectl exec -it openbao-0 -n prod-security -- bao operator unseal <UNSEAL_KEY_2>
kubectl exec -it openbao-0 -n prod-security -- bao operator unseal <UNSEAL_KEY_3>
```

Repeat for each pod (`openbao-1`, `openbao-2`, etc.).

---

## 🔒 Security posture

### TLS (recommended for production)

By default TLS is **disabled** for easy bootstrapping. Enable it for production:

1. Create a TLS secret:

```bash
kubectl create secret tls openbao-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n prod-security
```

2. Set in your values file:

```yaml
tls:
  enabled: true
  secretName: openbao-tls
```

### Security contexts

Production-hardened security context defaults are applied:

```yaml
podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000
  runAsGroup: 1000

containerSecurityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

### RBAC

Pod-scoped operations (patch/update) use a **namespaced Role**. Cluster-scoped read permissions (namespace/service/node discovery for HA) use a minimal **ClusterRole**.

---

## ⚙️ Configuration

### Hardened production values example

```yaml
serverReplicaCount: 3

tls:
  enabled: true
  secretName: openbao-tls

service:
  type: ClusterIP
  port: 8200

dataStorage:
  size: 20Gi
  storageClass: fast-ssd

resources:
  requests:
    cpu: 250m
    memory: 512Mi
  limits:
    cpu: 500m
    memory: 1Gi

podAntiAffinity: hard

podDisruptionBudget:
  enabled: true
  minAvailable: 2

networkPolicy:
  enabled: true

serviceAccount:
  create: true
  automountServiceAccountToken: true

podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8200"
  prometheus.io/path: "/v1/sys/metrics"
```

### Key values reference

| Parameter | Description | Default |
|---|---|---|
| `serverReplicaCount` | Number of OpenBao pods | `3` |
| `tls.enabled` | Enable TLS on the listener | `false` |
| `tls.secretName` | Name of the TLS Secret | `""` |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | API port | `8200` |
| `service.clusterPort` | Raft cluster port | `8201` |
| `dataStorage.size` | PVC size | `10Gi` |
| `dataStorage.storageClass` | StorageClass name | `""` (cluster default) |
| `resources` | Container resource requests/limits | see values.yaml |
| `podAntiAffinity` | `soft` or `hard` pod anti-affinity | `soft` |
| `podDisruptionBudget.enabled` | Enable PDB | `true` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `serviceAccount.create` | Create service account | `true` |
| `rbac.create` | Create RBAC resources | `true` |

---

## 🔄 Upgrade notes

- Config checksum annotations are applied to the pod template; config changes **automatically trigger rolling restarts**.
- StatefulSet uses `Parallel` pod management by default for faster rollouts.
- Always review OpenBao release notes before upgrading the `appVersion`.
- For Raft HA upgrades, upgrade one pod at a time and confirm cluster health before proceeding.
- **Avoid `helm upgrade --force`** — it forcefully replaces resources and can interrupt quorum.

---

## 🧹 Uninstall

```bash
helm uninstall openbao -n prod-security
```

> ⚠️ PVCs are **not** deleted automatically. Remove them manually if you want to clean up storage:
> ```bash
> kubectl delete pvc -l app.kubernetes.io/name=openbao -n prod-security
> ```

---

## 🧠 Naming conventions

| Concept | Format |
|---|---|
| Helm release | `openbao` |
| StatefulSet pods | `openbao-0`, `openbao-1`, `openbao-2` |
| Config ConfigMap | `openbao-config` |
| Headless service | `openbao-headless` |

---

## ⚠️ Important notes

- Persistent data is stored in PVCs (Raft storage) — back them up before upgrades.
- Unsealing is required after restart unless auto-unseal (KMS/transit) is configured.
- The chart disables TLS by default for ease of development; **always enable TLS in production**.
- Store unseal keys and root token in a secure external system, never in Kubernetes Secrets or version control.
