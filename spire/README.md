## 📘 SPIRE Helm Chart

Minimal Kubernetes deployment of SPIRE Server and SPIRE Agent using Helm.

---

## 📦 Install SPIRE

Create namespace + install:

```bash
helm install spire ./spire \
  -n spire \
  --create-namespace
```

---

## 📄 Verify Installation

Check pods:

```bash
kubectl get pods -n spire
```

Check SPIRE server:

```bash
kubectl logs -n spire statefulset/spire-server
```

Check SPIRE agent:

```bash
kubectl get pods -n spire -l app=spire-agent
```

---

## 🔄 Upgrade SPIRE

If you change values or templates:

```bash
helm upgrade spire ./spire -n spire
```

To force re-deploy:

```bash
helm upgrade spire ./spire -n spire --force
```

---

## 🧹 Uninstall SPIRE

Remove all resources:

```bash
helm uninstall spire -n spire
```

(Optional cleanup if namespace was created by Helm)

```bash
kubectl delete namespace spire
```

---

## ⚙️ Configuration

## values.yaml

```yaml
server:
  image: ghcr.io/spiffe/spire-server:1.14.5
  replicas: 1

agent:
  image: ghcr.io/spiffe/spire-agent:1.14.5

trustDomain: cluster.local
```

---

## 🧠 Architecture Overview

This chart deploys:

- SPIRE Server (StatefulSet)
- SPIRE Agent (DaemonSet)
- Kubernetes RBAC for node attestation
- ConfigMaps for server + agent configuration

---

## 🔐 Identity Model

SPIRE provides workload identity using SPIFFE IDs:

Example:

```
spiffe://cluster.local/ns/spire/sa/app
```

---

## 🧪 Troubleshooting

### Check SPIRE server logs

```bash
kubectl logs -n spire statefulset/spire-server
```

---

### Check SPIRE agent logs

```bash
kubectl logs -n spire daemonset/spire-agent
```

---

### Restart SPIRE components

```bash
kubectl rollout restart statefulset spire-server -n spire
kubectl rollout restart daemonset spire-agent -n spire
```

---

### Common issues

#### 1. Agent not connecting

- check `spire-server` service DNS
- verify port `8081`

#### 2. Pods not attesting

- verify RBAC permissions
- check `k8s_psat` plugin config