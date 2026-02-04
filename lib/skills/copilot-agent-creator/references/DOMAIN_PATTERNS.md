# Domain-Specific Patterns

Specialized sections and patterns for different agent domains.

## Overview

While all agents share core structure (Role, Responsibilities, Workflow, etc.), domain-specific agents often require additional sections that don't fit the standard template. This document catalogs proven patterns for specialized agent types.

## Infrastructure Operations (Kubernetes, Terraform)

### Risk Assessment Framework

Infrastructure agents should include explicit risk categorization:

```markdown
## Risk Assessment

Classify operations by impact:

**LOW RISK:**

- Read-only operations (get, describe, list)
- Dry-run validations
- Local/development cluster changes

**MEDIUM RISK:**

- Non-production resource modifications
- Reversible configuration changes
- Scaling operations with safeguards

**HIGH RISK:**

- Production resource modifications
- Destructive operations (delete, destroy)
- Namespace or state deletion
- Changes affecting multiple resources

**Action Required:**

- LOW → Proceed without confirmation
- MEDIUM → Dry-run + user notification
- HIGH → Explicit confirmation + rollback plan
```

### Confirmation Requirements

```markdown
## Confirmation Requirements

Request explicit "yes" confirmation before:

- Production deployments or applies
- Deleting resources (namespaces, PVs, databases)
- Bulk operations (--all, destroy with multiple resources)
- Modifying critical infrastructure (networking, IAM)
- Operations without rollback capability

**Confirmation format:**

- Present: operation summary, affected resources, risk level
- Require: explicit "yes" (not Y, yeah, ok)
- On decline: abort and explain next steps
```

### Environment Detection

```markdown
## Environment Safety

**Before ANY operation:**

1. Detect environment (local, staging, production)
2. Verify cluster/workspace context
3. Apply appropriate safety level

**Detection Methods:**

- Kubernetes: `kubectl config current-context`
- Terraform: workspace name + backend config
- Environment variables: `ENV`, `ENVIRONMENT`

**Default Assumption:** Treat unknown environments as PRODUCTION
```

## Development Agents (Code Implementation)

### Task Decision Matrix

Development agents need clear delegation logic:

```markdown
## Task Decision Matrix

**Implement Directly:**

- Single file edit (< 50 lines)
- Configuration changes
- Simple refactoring
- Adding tests for existing code
- Documentation updates
- Clear, well-defined scope

**Delegate to Subagent:**

- Multi-file changes across modules
- New features requiring research
- Complex refactoring/architecture changes
- Debugging unclear issues
- Tasks requiring exploration
- Ambiguous requirements

**Decision Criteria:**

- Complexity: single concern vs multiple concerns
- Clarity: requirements clear vs needs discovery
- Scope: isolated vs cross-cutting
- Risk: low-impact vs high-impact
```

### Implementation Loop

Development agents often need iterative workflows:

```markdown
## Implementation Loop

Repeat until all tasks complete:

1. **Load Change Context**
   - Read proposal.md, design.md, specs/\*.md, tasks.md
   - Check ERRORS.md and REQUIRED_FEEDBACK.md
   - Identify next incomplete task

2. **Assess Task**
   - Simple & clear → implement directly
   - Complex or unclear → delegate to subagent

3. **Execute**
   - Direct: make changes, run tests, verify
   - Delegate: launch subagent with task context

4. **Verify & Update**
   - Confirm task completion
   - Update task checkbox: `- [ ]` → `- [x]`
   - Handle errors or feedback

5. **Check Completion**
   - All tasks done? → Run verify skill
   - Blocked? → Report and wait
   - Continue? → Next iteration
```

### Error Handling

```markdown
## Error Handling

When errors occur:

1. **Capture Error Context**
   - Error message/stack trace
   - File and line number
   - Related task/change

2. **Attempt Resolution**
   - Fix syntax errors immediately
   - Retry transient failures (network, timing)
   - Research unfamiliar errors

3. **Escalate When Needed**
   - Ambiguous errors → Ask user
   - Architectural conflicts → Document in REQUIRED_FEEDBACK.md
   - Blockers → Update ERRORS.md and stop

**Never:**

- Skip errors silently
- Guess at fixes for critical errors
- Mark tasks complete when errors exist
```

## Advisory Agents (Consultants, Reviewers)

### Output Formats

Advisory agents should define structured deliverables:

```markdown
## Output Formats

### Technical Proposal Structure

\`\`\`markdown

# [Project Name] Technical Proposal

## Executive Summary

[3-4 sentences: Problem → Solution → Value]

## Requirements & Constraints

| ID  | Requirement | Key Constraint |
| --- | ----------- | -------------- |
| R1  | ...         | ...            |

## Architecture Strategy

[Diagram or description]

### Decision Matrix

| Feature | Option A | Option B | Recommendation |
| ------- | -------- | -------- | -------------- |
| ...     | ...      | ...      | ...            |

## Implementation Roadmap

1. Phase 1: [Deliverable]
2. Phase 2: [Deliverable]
3. Phase 3: [Deliverable]

## Risk Mitigation

- Risk: [description] → Mitigation: [approach]

## Cost Analysis

- Upfront: [amount]
- Recurring: [amount/month]
- TCO (3 years): [amount]
  \`\`\`
```

### Decision Framework

Consultants should use structured decision-making:

```markdown
## Decision Framework

**For architecture/technology choices:**

1. **Define NFRs** (Non-Functional Requirements)
   - Performance, scalability, reliability
   - Security, compliance, cost
   - Maintainability, team skill fit

2. **Generate Options** (2-4 viable alternatives)
   - Option A: [Technology/approach]
   - Option B: [Technology/approach]
   - Option C: [Technology/approach]

3. **Evaluate Against NFRs**
   | NFR | Weight | Opt A | Opt B | Opt C |
   |-----|--------|-------|-------|-------|
   | Perf | 3 | 8 | 6 | 9 |
   | Cost | 2 | 5 | 9 | 4 |
   | ... | ... | ... | ... | ... |

4. **Recommendation**
   - Recommended: [Option X]
   - Rationale: [Why it wins on weighted criteria]
   - Trade-offs: [What you're sacrificing]
```

### Communication Guidelines

```markdown
## Communication Guidelines

**Bottom Line Up Front (BLUF):**

- Lead with the answer/recommendation
- Context and details follow

**Precision:**

- Use exact terminology (latency vs throughput)
- Quantify when possible (< 100ms, 99.9% uptime)
- Avoid hedge words (probably, might, could)

**Objectivity:**

- Base on requirements, not preference
- Challenge user assumptions politely
- Provide evidence for claims

**Structure:**

- Use headers for skimmability
- Tables for comparisons
- Bullet points for lists
- Diagrams for complexity
```

## Triage/Investigation Agents (Debugging)

### Hypothesis-Driven Investigation

```markdown
## Investigation Method

**Scientific Approach:**

1. **Observe** → Document symptoms exactly
   - Error messages (full text)
   - When it occurs (frequency, timing)
   - What's affected (scope, blast radius)

2. **Hypothesize** → Generate possible causes
   - Configuration error
   - Resource constraint
   - Networking issue
   - Application bug
   - Dependency failure

3. **Test** → Gather evidence systematically
   - Check logs: `kubectl logs`, `terraform output`
   - Inspect resources: `describe`, `get -o yaml`
   - Review events: `kubectl events`
   - Validate config: syntax, values, references

4. **Analyze** → Match evidence to hypothesis
   - Which hypothesis explains the evidence?
   - Eliminate hypotheses without evidence
   - Identify root cause with confidence level

5. **Recommend** → Provide actionable fix
   - Fix: [specific steps]
   - Confidence: [High/Medium/Low]
   - Validation: [how to verify fix worked]
```

### Evidence Collection

```markdown
## Evidence Collection Checklist

**For Kubernetes Issues:**

- [ ] Pod status and phase
- [ ] Container restart count
- [ ] Recent logs (last 100 lines)
- [ ] Events (namespace and pod-level)
- [ ] Resource requests/limits vs usage
- [ ] Node conditions and capacity
- [ ] Related resources (services, configmaps, secrets)

**For Terraform Issues:**

- [ ] Plan output (full diff)
- [ ] State list
- [ ] Provider version
- [ ] Error message (full text)
- [ ] Affected resources
- [ ] Dependencies and data sources
- [ ] Backend configuration

**For Application Issues:**

- [ ] Error message and stack trace
- [ ] Recent code changes
- [ ] Environment variables
- [ ] External dependencies (DB, APIs)
- [ ] Load and traffic patterns
```

## Multi-Agent Orchestration

### Subagent Delegation

```markdown
## Subagent Management

**When to Delegate:**

- Task exceeds single agent's scope
- Specialized expertise required
- Complex research needed
- Parallel work possible (with caution)

**How to Delegate:**

1. **Prepare context**
   - Summarize task clearly
   - Provide relevant file paths
   - Specify expected deliverable

2. **Launch subagent**
   - ONE at a time (not parallel for dependent work)
   - With clear task description
   - With success criteria

3. **Monitor progress**
   - Track subagent completion
   - Handle subagent errors
   - Verify deliverable

4. **Integrate results**
   - Mark task complete
   - Update status
   - Continue workflow
```

### Progress Tracking

```markdown
## Progress Reporting

**After each task:**

Report format:
\`\`\`
**PROGRESS:** X/Y tasks complete
**CURRENT:** [what just finished]
**NEXT:** [what's next]
**STATUS:** [On track / Blocked / Error]
\`\`\`

**When blocked:**

\`\`\`
**BLOCKED:** [reason]
**IMPACT:** [what can't proceed]
**NEEDED:** [user input required]
\`\`\`
```

## Specialized Sections by Domain

### Kubernetes-Specific

```markdown
## Namespace Management

Protected namespaces (never modify without explicit permission):

- kube-system
- kube-public
- kube-node-lease
- default (in production)

## Manifest Validation

Before applying:

- [ ] Valid YAML syntax
- [ ] Required fields present
- [ ] Resource names valid (DNS-1123)
- [ ] No secrets in plaintext
- [ ] Resource limits defined
- [ ] Labels and selectors match
```

### Terraform-Specific

```markdown
## State Management

**Critical Rules:**

- Never edit state files manually
- Always back up state before major changes
- Use state locking (remote backends)
- Verify backend configuration before operations

## Plan Review

Before apply, verify plan shows:

- [ ] Expected resource changes only
- [ ] No unintended deletions
- [ ] No credential exposure
- [ ] No public resource creation (unless explicit)
- [ ] Dependencies resolved correctly
```

### OpenSpec-Specific

```markdown
## Artifact Management

**Active Change Detection:**
\`\`\`bash

# Find the most recent change

ls -t openspec/changes/ | head -n 1
\`\`\`

**Required Artifacts:**

- proposal.md → WHY (problem/solution)
- design.md → WHAT (architecture/approach)
- specs/\*.md → HOW (detailed implementation)
- tasks.md → TASKS (actionable items)

**Artifact Loading Priority:**

1. tasks.md (current work)
2. specs/\*.md (implementation details)
3. design.md (architecture context)
4. proposal.md (original intent)
```

## Domain-Specific Checklist

When creating a domain-specific agent, consider:

- [ ] **Risk framework** — How to classify operation risk?
- [ ] **Confirmation requirements** — When to require explicit approval?
- [ ] **Environment detection** —How to identify prod vs non-prod?
- [ ] **Decision matrix** — When to act vs delegate vs escalate?
- [ ] **Error handling** — How to capture, resolve, escalate?
- [ ] **Output formats** — What deliverables does the agent produce?
- [ ] **Investigation methods** — How to systematically debug?
- [ ] **Domain-specific validations** — What safety checks are unique?

---

**Key Takeaway:** Start with standard agent structure, then add domain-specific sections only when they provide unique value. Don't replicate what's already covered by core sections—extend, don't duplicate.
