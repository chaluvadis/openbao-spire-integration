## 📘 SPIRE Helm Chart

Production-ready deployment of **SPIRE** (SPIFFE Runtime Environment) for zero-trust workload identity on Kubernetes.

---

## 🧭 Prerequisites

- Kubernetes cluster (v1.24+)
- Helm 3+
- PostgreSQL instance accessible from the cluster (for SPIRE Server datastore)
- StorageClass available (for SPIRE Server persistent volume)

---

## 📦 Installation

### Create a database password Secret (required before install)

**Do not store the database password in `values.yaml`.** Create a Kubernetes Secret instead:

```bash
kubectl create namespace spire

kubectl create secret generic spire-postgres-credentials \
  --from-literal=password=<YOUR_DB_PASSWORD> \
  -n spire
```

### Install SPIRE

```bash
helm install spire ./spire \
  -n spire \
  --create-namespace \
  -f my-values.yaml
```

### Verify installation

```bash
# Check server
kubectl get pods -n spire -l app.kubernetes.io/component=server

# Check agents (one per node)
kubectl get pods -n spire -l app.kubernetes.io/component=agent

# View server logs
kubectl logs -n spire statefulset/spire-server
```

---

## 🔒 Security posture

### Database credentials

**Never store the Postgres password in `values.yaml`.** Use `storage.postgres.existingSecret`:

```yaml
storage:
  postgres:
    host: postgres.default.svc.cluster.local
    port: 5432
    db: spire
    user: spire
    existingSecret: spire-postgres-credentials
    existingSecretPasswordKey: password
    sslmode: require
```

The password is injected as an environment variable from the Secret — it never appears in ConfigMaps or Helm release history.

### Security contexts

Both server and agent use hardened security contexts by default:

```yaml
server:
  containerSecurityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: RuntimeDefault
```

The agent runs with `hostPID: true` (required for workload attestation) but drops all capabilities.

### RBAC

- **Server**: ClusterRole limited to `tokenreviews` (required for PSAT attestation)
- **Agent**: ClusterRole limited to read-only access to `pods`, `nodes`, `nodes/proxy`

---

## ⚙️ Configuration

### Hardened production values example

```yaml
trustDomain: example.com

server:
  replicas: 1
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
  podDisruptionBudget:
    enabled: true
    minAvailable: 1
  readinessProbe:
    enabled: true
  livenessProbe:
    enabled: true

agent:
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 256Mi

storage:
  postgres:
    host: postgres.spire.svc.cluster.local
    port: 5432
    db: spire
    user: spire
    existingSecret: spire-postgres-credentials
    existingSecretPasswordKey: password
    sslmode: require
  size: 2Gi

networkPolicy:
  enabled: true
```

### Key values reference

| Parameter | Description | Default |
|---|---|---|
| `trustDomain` | SPIFFE trust domain | `cluster.local` |
| `server.replicas` | Number of SPIRE Server pods | `1` |
| `server.port` | SPIRE Server gRPC port | `8081` |
| `server.resources` | Server container resources | see values.yaml |
| `server.podDisruptionBudget.enabled` | Enable PDB for server | `false` |
| `agent.resources` | Agent container resources | see values.yaml |
| `storage.postgres.existingSecret` | Secret name for DB password | `""` |
| `storage.postgres.sslmode` | Postgres SSL mode | `disable` |
| `storage.size` | PVC size for SPIRE Server | `1Gi` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |

---

## 🔄 Upgrade notes

- Config checksum annotations trigger automatic pod restarts on ConfigMap changes.
- SPIRE Server upgrades must be done carefully — always check the SPIRE release notes for datastore migration requirements before upgrading.
- Agent DaemonSets roll out automatically; verify agent health after upgrades.
- **Avoid `helm upgrade --force`** — it forcefully replaces resources and can interrupt identity issuance.

---

## 🧠 Architecture

This chart deploys:

- **SPIRE Server** — StatefulSet with Postgres datastore; issues SVIDs to attested workloads
- **SPIRE Agent** — DaemonSet; runs on each node, attests workloads and delivers SVIDs via a Unix socket

### Identity model

SPIFFE IDs take the form:

```
spiffe://cluster.local/ns/<namespace>/sa/<service-account>
```

### Workload registration example

```bash
kubectl exec -n spire spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
  -spiffeID spiffe://cluster.local/ns/default/sa/myapp \
  -parentID spiffe://cluster.local/ns/spire/sa/spire-agent \
  -selector k8s:ns:default \
  -selector k8s:sa:myapp
```

---

## 🧹 Uninstall

```bash
helm uninstall spire -n spire
kubectl delete pvc -l app.kubernetes.io/name=spire -n spire
```

---

## 🧪 Troubleshooting

**Agents not connecting to server:**
```bash
kubectl logs -n spire -l app.kubernetes.io/component=agent
# Check that server is reachable and trust bundle is valid
```

**Server not starting:**
```bash
kubectl logs -n spire statefulset/spire-server
# Check Postgres connectivity and credentials
```

**Token review failures:**
```bash
# Verify server ClusterRole includes tokenreviews
kubectl auth can-i create tokenreviews --as=system:serviceaccount:spire:spire-server
```

**Restart components:**
```bash
kubectl rollout restart statefulset spire-server -n spire
kubectl rollout restart daemonset spire-agent -n spire
```
