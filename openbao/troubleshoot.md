Here’s a clean **`troubleshoot.md`** you can store and reuse for your OpenBao Kubernetes deployment journey.

---

````md
# OpenBao Kubernetes Troubleshooting Guide

This document summarizes common issues, root causes, and fixes for OpenBao HA (Raft) deployments on Kubernetes.

---

# 1. Cluster fails: "cluster address must be set when using raft storage"

## Cause
Missing or invalid cluster identity configuration for Raft.

## Fix
Ensure config includes:

```hcl
listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
}

storage "raft" {
  path = "/openbao/data"
}

api_addr = "http://openbao.openbao.svc.cluster.local:8200"
````

---

# 2. Invalid hostname error (${POD_NAME} not working)

## Cause

Shell-style variables are not expanded in HCL.

## Fix

Do NOT use:

```
${POD_NAME}
```

Use Kubernetes DNS or remove dynamic interpolation:

```
openbao-0.openbao-headless
```

Better:

```
api_addr = "http://openbao.openbao.svc.cluster.local:8200"
```

---

# 3. ConfigMap missing / mount errors

## Cause

StatefulSet references a ConfigMap that does not exist.

## Fix

Verify:

```bash
kubectl get configmap -n openbao
```

Recreate ConfigMap before StatefulSet rollout.

---

# 4. Kubernetes service_registration 403 Forbidden

## Cause

Missing RBAC permissions for pod PATCH operations.

## Fix (ClusterRole)

```yaml
rules:
- apiGroups: [""]
  resources:
    - pods
    - pods/status
    - namespaces
  verbs:
    - get
    - list
    - watch
    - patch
    - update
```

---

# 5. "too many open files" (fsnotify error)

## Cause

Linux inotify limits too low.

## Fix (StatefulSet security context)

```yaml
securityContext:
  fsGroup: 1000
  fsGroupChangePolicy: OnRootMismatch
```

Optional node-level fix:

```
fs.inotify.max_user_watches=524288
```

---

# 6. CLI not found inside pod

## Cause

OpenBao image does not expose CLI as `openbao`.

## Fix

Use:

```bash
bao status
```

Check binary:

```bash
which bao
```

---

# 7. HTTPS vs HTTP mismatch error

## Cause

CLI defaults to HTTPS but server runs HTTP.

## Fix

```bash
export BAO_ADDR=http://127.0.0.1:8200
```

---

# 8. Login works but token not saved

## Cause

Container has no write access to home directory.

## Fix

```bash
export HOME=/tmp
bao login
```

Or ignore persistence and set:

```bash
export BAO_TOKEN=<token>
```

---

# 9. Permission denied on raft list-peers (403)

## Cause

No authentication token set.

## Fix

```bash
bao login
```

or:

```bash
export BAO_TOKEN=<root-token>
```

---

# 10. Raft cluster not forming

## Check list:

* Headless service exists
* StatefulSet serviceName matches
* Ports 8200 & 8201 exposed
* api_addr is valid DNS

---

# 11. Expected healthy state

```text
Initialized: true
Sealed: false
HA Enabled: true
Storage Type: raft
```

---

# 12. Debug commands

```bash
kubectl get pods -n openbao
kubectl logs -f openbao-0 -n openbao
bao status
bao operator raft list-peers
```

---

# 13. Recommended production improvements

* Enable auto-unseal (KMS / cloud provider)
* Enable TLS (remove tls_disable)
* Replace manual root token usage with auth method:

  * Kubernetes auth
  * OIDC
  * AppRole

---

# Summary

Most issues come from:

* incorrect Raft addressing
* missing RBAC permissions
* container filesystem restrictions
* CLI vs server confusion

Once fixed, OpenBao runs stable HA Raft clusters on Kubernetes.

```