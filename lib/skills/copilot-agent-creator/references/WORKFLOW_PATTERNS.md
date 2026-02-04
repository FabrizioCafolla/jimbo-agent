# Workflow Patterns

Common workflow structures for Copilot Custom Agents.

## Workflow Design Principles

1. **3-5 Stages** — Keep workflows digestible, not overwhelming
2. **Sequential Logic** — Each stage builds on the previous
3. **Clear Deliverables** — Each stage has a concrete output
4. **Consistent Naming** — Use similar stage names across agents
5. **Validation Gates** — Critical checks between stages

## Standard Workflow Template

Most agents follow this general pattern:

```markdown
## Workflow (5 Stages)

1. **Context** → [Information gathering]
2. **Planning** → [Task breakdown & risk assessment]
3. **Validation** → [Safety checks & dry-runs]
4. **Execution** → [Primary action]
5. **Verification** → [Confirm success & report]
```

This template can be adapted to specific domains.

## Common Workflow Patterns

### Pattern 1: Operational Workflow (Infrastructure Agents)

**Use case:** Kubernetes, Terraform, deployment agents

```markdown
## Workflow (5 Stages)

1. **Context** → Gather cluster/workspace state, verify environment
2. **Planning** → Break down task, assess risk level
3. **Validation** → Dry-run and safety checks
4. **Execution** → Apply changes with confirmation when needed
5. **Verification** → Confirm desired state reached
```

**Key characteristics:**

- Heavy emphasis on validation (stage 3)
- Confirmation requirements in execution (stage 4)
- State verification (stage 5)
- Safety-first approach

**Example (Kubernetes Agent):**

```markdown
## Workflow (5 Stages)

1. **Context** → Gather cluster state, verify context
2. **Planning** → Break down task, assess risk
3. **Validation** → Dry-run and manifest checks
4. **Execution** → Apply with confirmation when needed
5. **Verification** → Confirm desired state reached
```

### Pattern 2: Development Workflow (Code Implementation)

**Use case:** Developer agents, feature implementation

```markdown
## Workflow (5 Stages)

1. **Discovery** → Identify active change, load artifacts
2. **Context** → Read contextFiles and task status
3. **Execution** → Implement directly OR launch subagent
4. **Verification** → Confirm task complete, handle errors
5. **Completion** → Run verify/archive when done
```

**Key characteristics:**

- Artifact-driven (stage 1-2)
- Delegation logic (stage 3)
- Task tracking integration (stage 4)
- Verification before completion (stage 5)

**Example (Developer Agent):**

```markdown
## Workflow (5 Stages)

1. **Discovery** → Identify active change, load artifacts
2. **Context** → Read contextFiles and task status
3. **Execution** → Implement directly OR launch subagent
4. **Verification** → Confirm task complete, handle errors
5. **Completion** → Run verify/archive when done
```

### Pattern 3: Advisory Workflow (Consulting/Review)

**Use case:** Consultant agents, reviewers, strategists

```markdown
## Workflow (4 Stages)

1. **Requirement Gathering** → Understand needs, constraints
2. **Analysis** → Research options, assess trade-offs
3. **Recommendation** → Propose solution with rationale
4. **Documentation** → Deliver structured output
```

**Key characteristics:**

- No execution stage (advisory only)
- Focus on analysis and recommendations
- Structured deliverables (stage 4)
- Typically 4 stages (no execution)

**Example (Consultant Agent):**

```markdown
## Workflow (Architecture Design)

1. **Requirement Extraction** → Identify FRs and NFRs
2. **Constraint Identification** → Budget, compliance, team skills
3. **Option Generation** → Propose 2-3 viable architectures
4. **Trade-off Analysis** → Compare using NFR metrics
5. **Recommendation** → State recommended path with rationale
```

### Pattern 4: Investigation Workflow (Triage/Debug)

**Use case:** Troubleshooting, root cause analysis

```markdown
## Workflow (5 Stages)

1. **Symptom Collection** → Gather error messages, logs, state
2. **Hypothesis Generation** → List possible root causes
3. **Evidence Gathering** → Test hypotheses systematically
4. **Root Cause Identification** → Determine actual cause
5. **Recommendation** → Suggest fix with confidence level
```

**Key characteristics:**

- Scientific method approach
- Evidence-based progression
- No fix implementation (recommendation only)
- Confidence scoring

**Example (Kubernetes Triage Skill):**

```markdown
## Investigation Process

1. **Observation** → What is the failure? (Pod crashloop, networking issue)
2. **Hypothesis** → What could cause this? (Image pull, config, resource limits)
3. **Evidence** → Check logs, describe resources, events
4. **Analysis** → Identify root cause from evidence
5. **Recommendation** → Provide fix with confidence rating
```

### Pattern 5: Progressive Elaboration (Multi-Artifact Creation)

**Use case:** OpenSpec workflows, phased design processes

```markdown
## Workflow (Artifact Progression)

1. **Proposal** → Define problem and high-level solution
2. **Design** → Architect detailed approach
3. **Specification** → Create implementation specs
4. **Tasks** → Break into actionable units
5. **Implementation** → Execute tasks
6. **Verification** → Validate completeness
```

**Key characteristics:**

- Each stage creates an artifact
- Non-linear (can iterate or skip stages)
- User-guided progression
- Clear exit criteria per stage

## Workflow Variations

### Short Workflow (3 Stages)

**When to use:** Simple, focused agents with narrow scope

```markdown
## Workflow (3 Stages)

1. **Analyze** → Understand request and constraints
2. **Execute** → Perform primary action
3. **Verify** → Confirm success
```

**Example use cases:**

- Single-purpose utility agents
- Highly specialized tools
- Agents with limited scope

### Extended Workflow (6+ Stages)

**When to use:** Complex, multi-phase processes

```markdown
## Workflow (7 Stages)

1. **Initial Triage** → Classify request type
2. **Context Gathering** → Collect all relevant information
3. **Risk Assessment** → Evaluate impact and dependencies
4. **Strategy Planning** → Define approach and milestones
5. **Incremental Execution** → Execute in phases
6. **Continuous Validation** → Verify each phase
7. **Final Verification** → Comprehensive checks
```

**Caution:** More stages = more complexity. Only extend when truly necessary.

## Creating Custom Workflows

### Step 1: Map the Natural Phases

List what naturally happens when performing the task manually:

**Example: Deploying a service**

1. Check cluster state
2. Review service requirements
3. Create manifest
4. Validate manifest syntax
5. Test in staging
6. Deploy to production
7. Monitor deployment
8. Verify health

### Step 2: Group Into Logical Stages

Consolidate related steps into stages:

1. **Context** → Steps 1-2 (gather state & requirements)
2. **Planning** → Step 3 (create manifest)
3. **Validation** → Steps 4-5 (validate & test)
4. **Execution** → Steps 6-7 (deploy & monitor)
5. **Verification** → Step 8 (verify health)

### Step 3: Define Stage Deliverables

Each stage should produce something concrete:

```markdown
1. **Context** → Cluster state snapshot + requirement checklist
2. **Planning** → Draft manifest file
3. **Validation** → Validation report + test results
4. **Execution** → Deployment status + resource IDs
5. **Verification** → Health check report
```

### Step 4: Add Decision Points

Identify where the workflow might branch or pause:

```markdown
3. **Validation** → If validation fails: STOP and fix
4. **Execution** → If production deployment: request confirmation
5. **Verification** → If health checks fail: rollback
```

### Step 5: Document the Workflow

Write it in the standard format:

```markdown
## Workflow (5 Stages)

1. **Context** → Gather cluster state and service requirements
2. **Planning** → Create and review manifest
3. **Validation** → Validate syntax and test in staging
   - **Gate:** Validation must pass before proceeding
4. **Execution** → Deploy to target environment
   - **Gate:** Production deployments require explicit confirmation
5. **Verification** → Monitor deployment and verify health
   - **Action:** Rollback if health checks fail
```

## Workflow Integration with Checklists

Workflows and checklists work together:

```markdown
## Workflow (5 Stages)

1. **Context** → Gather information
2. **Planning** → Design approach
3. **Validation** → Safety checks ← PRE-ACTION CHECKLIST RUNS HERE
4. **Execution** → Take action
5. **Verification** → Confirm success

## Pre-Action Checklist

- [ ] Stage 1-2 completed?
- [ ] All context gathered?
- [ ] Risk level assessed?
- [ ] Confirmation obtained (if high-risk)?

**On failure:** STOP and remediate
```

The checklist acts as a gate between Planning (stage 2) and Execution (stage 4).

## Common Workflow Mistakes

### ❌ Too Many Stages

```markdown
## Workflow (12 Stages)

1. Initialize
2. Authenticate
3. Validate authentication
4. Load context
5. Parse context
6. Validate context
   ...
```

**Problem:** Overwhelming complexity, no clear phase boundaries

**Fix:** Consolidate related steps into logical stages (3-5)

### ❌ Vague Stage Names

```markdown
## Workflow

1. **Preparation** → Do stuff
2. **Processing** → Handle things
3. **Completion** → Finish
```

**Problem:** Unclear what each stage actually does

**Fix:** Use specific, descriptive stage names

### ❌ Missing Decision Logic

```markdown
## Workflow

1. **Context** → Gather state
2. **Execution** → Apply changes
3. **Verification** → Check results
```

**Problem:** No planning, validation, or risk assessment

**Fix:** Add Planning and Validation stages with clear gates

### ❌ Inconsistent Structure Across Agents

```markdown
# Agent A

1. Setup → Planning → Execution → Done

# Agent B

1. Discovery → Analysis → Implementation → Validation → Archival

# Agent C

wn

# Agent A

1. Setup → Planning → Execution → Done

# Agent B

1. Discovery → Analysis → Implementation → Validation → Archival

# Agent C

1. Init → Process → Finish
```

**Problem:** Hard to learn patterns, inconsistent mental models

**Fix:** Use consistent stage naming across similar agents

## Workflow Checklist

When defining a workflow, verify:

- [ ] **3-5 stages** (or clear reason for deviation)
- [ ] **Sequential logic** (each stage builds on previous)
- [ ] **Clear deliverables** (each stage produces something)
- [ ] **Decision points identified** (where to pause/branch)
- [ ] **Validation gates** (before risky operations)
- [ ] **Consistent naming** (matches similar agents)
- [ ] **Integrated with checklist** (workflow ↔ checklist alignment)

---

**Key Takeaway:** Workflows provide structure without rigidity. They guide behavior while allowing flexibility for context-specific decisions. Keep them simple, clear, and consistent.
