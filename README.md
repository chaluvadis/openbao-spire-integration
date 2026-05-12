# 🏗️ Zero Trust Kubernetes Architecture (SPIRE + OpenBao)

## 1. Purpose

This document describes a **zero trust security architecture for Kubernetes** using:

- workload identity (SPIRE)
- centralized secrets and PKI (OpenBao)
- multi-cluster trust federation

The goal is to eliminate static secrets and replace them with **short-lived, identity-based access control**.

---

## 2. Goals

- Provide every workload with a **verifiable identity**
- Eliminate long-lived credentials in Kubernetes
- Enable **automatic rotation of certificates and secrets**
- Support **multi-cluster secure communication**
- Centralize PKI and secrets governance
- Enforce zero trust between services

---

## 3. High-Level Architecture

```text id="arch-simple"
                     ┌──────────────────────┐
                     │      OpenBao         │
                     │  (Secrets + PKI CA)  │
                     └─────────┬────────────┘
                               │
             Trust bundles + dynamic secrets
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
   Kubernetes Cluster A   Kubernetes Cluster B   Kubernetes Cluster C
        │                      │                      │
   ┌────────────┐        ┌────────────┐        ┌────────────┐
   │ SPIRE      │        │ SPIRE      │        │ SPIRE      │
   │ Server     │        │ Server     │        │ Server     │
   └─────┬──────┘        └─────┬──────┘        └─────┬──────┘
         │                     │                     │
   ┌────────────┐        ┌────────────┐        ┌────────────┐
   │ SPIRE      │        │ SPIRE      │        │ SPIRE      │
   │ Agent      │        │ Agent      │        │ Agent      │
   └─────┬──────┘        └─────┬──────┘        └─────┬──────┘
         │                     │                     │
      Workloads            Workloads            Workloads
```

---

## 4. Components and Responsibilities

### 4.1 OpenBao (Central Security System)

OpenBao

**Responsibilities:**

- Acts as the **central trust authority**
- Issues and manages:
  - secrets (DB credentials, API keys)
  - certificates (PKI)

- Defines access policies
- Provides audit logging

**Role in architecture:**

> “Security brain of the system”

---

### 4.2 SPIRE (Workload Identity System)

SPIRE

**Responsibilities:**

- Assigns **unique identity to every workload**
- Issues short-lived certificates (SVIDs)
- Enables service-to-service authentication
- Rotates identities automatically

**Role in architecture:**

> “Identity provider for all workloads”

---

### 4.3 SPIRE Server (Per Cluster Control Plane)

**Responsibilities:**

- Manages workload identity rules
- Issues identities based on registration entries
- Communicates with OpenBao for trust anchors
- Handles federation with other clusters

---

### 4.4 SPIRE Agent (Node-Level Component)

**Responsibilities:**

- Runs on every Kubernetes node
- Attests node and workload identity
- Delivers identity to pods
- Rotates identities automatically

---

### 4.5 Kubernetes Cluster

**Responsibilities:**

- Runs workloads (pods, services)
- Hosts SPIRE components
- Enforces network policies
- Executes identity-based authentication

---

## 5. Identity and Secret Flow

### 5.1 Workload Identity Flow

1. Pod starts in Kubernetes
2. SPIRE Agent verifies workload
3. SPIRE Server issues identity (SPIFFE ID)
4. Pod receives short-lived certificate
5. Identity is used for all service-to-service communication

---

### 5.2 Secret Access Flow

1. Workload authenticates using SPIRE identity
2. Request is sent to OpenBao
3. OpenBao validates identity
4. OpenBao issues **temporary secret (TTL-based)**
5. Secret expires automatically after TTL

---

## 6. Multi-Cluster Trust Model

- Each cluster has its own SPIRE Server
- OpenBao acts as global trust authority
- SPIRE Servers exchange trust bundles
- Cross-cluster identity verification enabled via federation

---

## 7. Security Model (Zero Trust Principles)

- No implicit trust between services
- Every request is authenticated using identity
- All credentials are short-lived
- Network is considered untrusted by default
- Access is granted per identity, not per IP or network

---

## 8. Rotation Strategy

| Resource Type            | Mechanism | Rotation Interval         |
| ------------------------ | --------- | ------------------------- |
| Workload identity        | SPIRE     | Minutes                   |
| Service-to-service certs | SPIRE     | Automatic                 |
| DB/API secrets           | OpenBao   | Minutes–Hours (TTL-based) |
| Root/intermediate CA     | OpenBao   | Long-lived, controlled    |

---

## 9. Key Benefits

- Eliminates static credentials in workloads
- Enables true zero trust networking
- Supports multi-cluster environments
- Centralized security governance
- Automated rotation of all sensitive material
- Strong auditability and compliance support

---

## 10. Summary

This architecture builds a **zero trust Kubernetes platform** where:

- SPIRE provides **who the workload is**
- OpenBao provides **what the workload can access**
- Kubernetes provides **where workloads run**

Together, they form a system where:

> No service is trusted by default, and everything is continuously verified and rotated.

---

If you want next, I can turn this into:

- a **diagram (C4 model / architecture poster)**
- a **production Helm deployment guide based on this doc**
- or a **GitOps repository structure (ArgoCD-ready)**
