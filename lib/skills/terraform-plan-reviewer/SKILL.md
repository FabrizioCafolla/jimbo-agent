---
name: terraform-plan-reviewer
description: Specialized skill for deep review and risk assessment of Terraform plans. Use this to analyze `terraform plan` outputs, predict downtime, identify destructive changes, and validate security impact before applying.
license: MIT
metadata:
  author: Fabrizio Cafolla
  version: '1.0'
---

## When to Use This Skill

- You have a `terraform plan` output (file or console logs) and need a second opinion.
- You see `(forces replacement)` and want to understand the downtime impact.
- You are reviewing a Pull Request containing Terraform changes.
- You need to validate compliance or security implications of a change.

## Prerequisites

- The full output of `terraform plan` (or `terraform show -json tfplan`).
- Knowledge of the target environment (Production vs Non-Prod).
- Access to provider documentation (for verifying `force_new` attributes).

## Core Philosophy: The Paranoid Auditor

- **Guilty until proven innocent:** Every change is potential downtime.
- **Read the fine print:** A single attribute change can trigger a resource replacement.
- **Context matters:** A database replacement in Dev is an inconvenience; in Prod, it's an outage.
- **External Intelligence:** Don't just trust the plan; check if the provider version has known bugs.

## Review Protocol

### Phase 1: High-Level Impact Assessment

Analyze the plan summary stats (`Plan: X to add, Y to change, Z to destroy`).

- **Green Flag:** Plan fits expected behavior (e.g., adding a tag).
- **Yellow Flag:** Modifications in place.
- **Red Flag:** Destructions or Replacements of stateful resources (DBs, Storage, IPs).

### Phase 2: Destructive Change Forensics

For every resource with `status: destroyed` or `status: replaced` (typically marked with `-/+`):

1.  **Identify the Trigger:** Which attribute caused the replacement? Look for `forces replacement` in the plan.
2.  **Downtime Prediction:**
    - _Stateless (e.g., EC2, ASG):_ Is there a rolling update strategy?
    - _Stateful (e.g., RDS, S3, EBS):_ **CRITICAL RISK.** Will data be lost? Is a snapshot taken?
    - _Network (e.g., EIP, ENI, LB):_ Will the endpoint change? DNS propagation delay?
3.  **Validation:** "Is this replacement strictly necessary or is it a provider interpretation issue?"

### Phase 3: External Intelligence Gathering

If a complex resource is changing (e.g., `aws_eks_cluster`, `google_sql_database_instance`):

1.  **Search Known Issues:** Look for GitHub issues in the provider repo related to the resource and version.
    - _Query:_ `site:github.com/hashicorp/terraform-provider-aws issues "aws_eks_cluster" modification`
2.  **Verify API Behavior:** Check cloud provider docs. Does modifying "X" really require replacement?

### Phase 4: Security & Compliance Audit

Scan the plan for sensitive exposures:

- **Network:** `0.0.0.0/0` in Security Groups/Firewalls.
- **Encryption:** `encrypted = false` or missing KMS keys.
- **Identity:** Wildcard IAM roles (`Action: *`, `Resource: *`).
- **Data:** Public S3 buckets or unauthenticated endpoints.

## Output Standard: The Risk Report

Deliver a structured report.

### 1. Executive Summary

"This plan introduces **High Risk** changes involving the replacement of the primary database."

### 2. Critical Impact Analysis

| Resource                 | Action            | Reason                     | Downtime Risk               |
| :----------------------- | :---------------- | :------------------------- | :-------------------------- |
| `aws_db_instance.main`   | **REPLACE (-/+)** | Change in `engine_version` | **HIGH** (20-40 min outage) |
| `aws_security_group.web` | MODIFY (~)        | Adding Ingress Rule        | NONE                        |

### 3. Deep Dive Findings

- **Issue:** The RDS instance is being replaced because `availability_zone` was changed manually.
- **Intelligence:** GitHub Issue #1234 suggests this can be avoided by...
- **Security:** Warning: Port 22 is being opened to the world.

### 4. Recommendation

- **[ ] BLOCK:** Do not apply until DB snapshot is confirmed.
- **[ ] APPROVE:** Changes are safe.
