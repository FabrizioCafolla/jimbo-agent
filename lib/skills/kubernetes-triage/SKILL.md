---
name: kubernetes-triage
description: Specialized skill for deep Kubernetes error investigation, bug hunting, and analytical troubleshooting. Use this to systematically diagnose malfunctions, identifying root causes through evidence-based analysis.
license: MIT
metadata:
  author: Fabrizio Cafolla
  version: '1.0'
---

## When to Use This Skill

- Investigating `CrashLoopBackOff`, `ImagePullBackOff`, `Pending`, or `Error` states.
- Troubleshooting connectivity issues (Service, Ingress, DNS).
- Diagnosing performance degradation (CPU throttling, OOMKilled).
- Performing a systematic root cause analysis of infrastructure failures.

## Prerequisites

- Active `kubectl` context configured for the target cluster.
- Read permissions for the relevant namespace (or ClusterRole for node inspection).
- Basic understanding of Kubernetes resources (Pod, Deployment, Service).

## Core Philosophy: The Analytical Investigator

- **Evidence First:** Do not guess. Gather logs, events, and metrics before forming a hypothesis.
- **Isolate Variables:** Change one thing at a time when debugging.
- **Non-Destructive by Default:** Read-only operations until the root cause is confirmed.
- **Systematic:** Follow the triage phases strictly.

## Investigation Protocol (Step-by-Step)

### Phase 1: Context & Scope (The "Crime Scene")

Determine if the issue is systemic (Cluster/Node) or local (Pod/Service).

```bash
# Verify Context
kubectl config current-context

# Cluster/Node Health (Is the platform healthy?)
kubectl get nodes -o wide
kubectl top nodes

# Workload State (What is broken?)
kubectl get all -n {ns} -o wide | grep -v Runn
kubectl get events -n {ns} --sort-by=.metadata.creationTimestamp | tail -20
```

### Phase 2: Deep Data Collection (Evidence Gathering)

Zoom in on the failing component.

**For Workloads (CrashLoop/Error/Pending):**

```bash
# Configuration & State
kubectl describe pod {pod} -n {ns}

# Application Logs (Current & Previous)
kubectl logs {pod} -n {ns} --all-containers=true --tail=50
kubectl logs {pod} -n {ns} --previous --tail=50

# Resource Usage (Is it OOM/CPU throttling?)
kubectl top pod {pod} -n {ns}
```

**For Networking (Service/Ingress/DNS):**

```bash
# Endpoint check (Is traffic going anywhere?)
kubectl get endpoints {svc} -n {ns}

# DNS Debug (Run ephemeral container if needed)
kubectl debug -it {pod} --image=curlimages/curl -- sh
# Inside debug pod: nslookup {service}.{ns}
```

### Phase 3: Analytical Root Cause Analysis

Analyze the collected evidence against these common patterns.

#### 1. Application Layer

- **Signal:** Exit Code 1 / 137 (OOM) / 0 (Misconfig).
- **Check:** Application logs for exceptions, env var mismatches (`kubectl describe pod` > Environment).

#### 2. Configuration Layer

- **Signal:** `CreateContainerConfigError` / `ImagePullBackOff`.
- **Check:** Secrets/ConfigMaps existence, permissions, Image tags.

#### 3. Resource/Scheduling Layer

- **Signal:** `Pending` / `Evicted`.
- **Check:** `kubectl describe node` (Taints), PVC status (`kubectl get pvc`), Quotas.

#### 4. Network Layer

- **Signal:** Timeouts / 50X errors.
- **Check:** NetworkPolicies, Service Selectors matches Pod Labels.

### Phase 4: Hypothesis & Verification

Before fixing, state your hypothesis.

- **Hypothesis:** "The pod is crashing because the DB password secret is missing."
- **Verification:** `kubectl get secret db-pass -n {ns}` (Expect: NotFound).

### Phase 5: Remediation Plan

Propose fixes ranked by risk.

1.  **Low Risk:** Config change, Rollout restart (`kubectl rollout restart deploy/{name}`).
2.  **Medium Risk:** Rollback (`kubectl rollout undo`).
3.  **High Risk:** Resource editing/deletion (Requires backup).

## Output Standard

**1. Situation Summary**
"Pod X is in CrashLoopBackOff due to a Panic in main.go."

**2. Evidence Locker**

- `kubectl describe`: "Exit Code 137 (OOMKilled)"
- `logs`: "panic: nil pointer dereference"

**3. Proposed Fixes**

- **Option A (Recommended):** Increase Memory Limit.
  - _Cmd:_ `kubectl patch ...`
- **Option B:** Rollback to v1.2.
  - _Cmd:_ `kubectl rollout undo ...`

**4. Validation Steps**
"After applying, watch `kubectl get pods -w` until Ready 1/1."
