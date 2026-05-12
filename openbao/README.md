# 📘 OpenBao Helm Chart

This chart deploys **OpenBao** as a high-availability secrets and PKI system on Kubernetes using StatefulSet (Raft storage).

---

# 🧭 Prerequisites

- Kubernetes cluster (v1.24+ recommended)
- Helm 3+
- StorageClass available (for persistent volumes)

---

# 📦 1. Installation

## 1.1 Create namespace

You must create a namespace before installing OpenBao:

```bash id="i1"
kubectl create namespace <namespace-name>
```

Example:

```bash id="i2"
kubectl create namespace dev-security
```

---

## 1.2 Install OpenBao

```bash id="i3"
helm install <release-name> ./openbao \
  -n <namespace-name>
```

Example:

```bash id="i4"
helm install openbao ./openbao \
  -n dev-security
```

---

## 1.3 Verify installation

```bash id="i5"
kubectl get pods -n <namespace-name>
kubectl get svc -n <namespace-name>
```

Example:

```bash id="i6"
kubectl get pods -n dev-security
```

---

# 🔐 2. First-time initialization (IMPORTANT)

After installation, OpenBao starts in a **sealed state**.

## 2.1 Initialize cluster

```bash id="i7"
kubectl exec -it <release-name>-0 -n <namespace-name> -- openbao operator init
```

Example:

```bash id="i8"
kubectl exec -it openbao-0 -n dev-security -- openbao operator init
```

You will receive:

- unseal keys
- root token

---

## 2.2 Unseal nodes

Run for each pod:

```bash id="i9"
kubectl exec -it <pod-name> -n <namespace-name> -- openbao operator unseal
```

---

# 🔄 3. Upgrade OpenBao

To update configuration or version:

```bash id="i10"
helm upgrade <release-name> ./openbao \
  -n <namespace-name>
```

Example:

```bash id="i11"
helm upgrade openbao ./openbao \
  -n dev-security
```

---

# 🧹 4. Uninstall OpenBao

## 4.1 Delete Helm release

```bash id="i12"
helm uninstall <release-name> -n <namespace-name>
```

Example:

```bash id="i13"
helm uninstall openbao -n dev-security
```

---

## 4.2 Delete namespace (IMPORTANT)

⚠️ This will remove ALL resources inside the namespace including PVCs (if not retained).

```bash id="i14"
kubectl delete namespace <namespace-name>
```

Example:

```bash id="i15"
kubectl delete namespace dev-security
```

---

# 🧠 5. Naming conventions

| Concept          | Format                                              |
| ---------------- | --------------------------------------------------- |
| Helm release     | `openbao`                                           |
| Namespace        | environment-based (`dev-security`, `prod-security`) |
| StatefulSet pods | `openbao-0`, `openbao-1`                            |

---

# ⚠️ 6. Important notes

- Do NOT hardcode namespace inside templates
- Always use Helm release name for resource identity
- Persistent data is stored in PVCs (Raft storage)
- Unsealing is required after restart unless auto-unseal is configured later
