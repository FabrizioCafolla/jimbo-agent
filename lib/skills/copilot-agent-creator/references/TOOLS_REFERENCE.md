# Tools Reference

Complete guide for configuring agent tool permissions.

## Tool Configuration Principles

1. **Principle of Least Privilege** — Grant only tools required for the agent's responsibilities
2. **Use Wildcards Appropriately** — Use category wildcards (`execute/*`) not blanket access
3. **Match Tools to Risk Profile** — Operational agents ≠ Advisory agents
4. **Document Tool Rationale** — Know why each tool is included

## Tool Categories

### Core Tools (Almost Always Included)

```yaml
tools:
  - read/readFile # Read files from workspace
  - search # Search codebase (grep, semantic)
  - agent # Delegate to subagents
  - todo # Task tracking
```

**When to include:**

- `read/readFile`: Any agent that needs to understand code/config
- `search`: Any agent working with existing codebases
- `agent`: Agents that can delegate complex work
- `todo`: Agents managing multi-step workflows

### Execution Tools (Operational Agents)

```yaml
tools:
  - execute/* # Run terminal commands
```

**Grants access to:**

- `execute/terminal` — Run shell commands
- `execute/background` — Start long-running processes

**When to include:**

- Agents that deploy resources (Kubernetes, Terraform)
- Agents that run tests or builds
- Agents that need CLI tools (kubectl, terraform, gh)

**When to exclude:**

- Advisory agents (consultants, reviewers)
- Agents focused on planning/design
- Agents without operational responsibilities

**Safety note:** Always pair with strong guardrails and confirmation requirements.

### Edit Tools (Code Modification)

```yaml
tools:
  - edit/* # All edit operations
```

**Grants access to:**

- `edit/file` — Modify existing files
- `edit/create` — Create new files
- `edit/replace` — Replace strings in files
- `edit/multi-replace` — Batch replacements

**When to include:**

- Developer agents implementing code
- Agents managing configuration files
- Agents creating documentation

**When to exclude:**

- Read-only advisory agents
- Agents focused on analysis/review

**Alternative (more restrictive):**

```yaml
tools:
  - edit/file # Allow modification only
  - edit/replace # Allow targeted replacements
  # Exclude edit/create to prevent file creation
```

### Web Access

```yaml
tools:
  - web # Fetch web content
```

**Grants access to:**

- Fetching documentation
- Checking API references
- Researching best practices

**When to include:**

- Agents that need external knowledge
- Agents researching solutions
- Agents validating against documentation

**When to exclude:**

- Fully offline agents
- Agents with complete domain knowledge in context

### File System Tools (Advanced Operations)

```yaml
tools:
  - filesystem/* # MCP filesystem operations
```

**Grants access to:**

- Directory tree visualization
- Bulk file operations
- File metadata inspection
- Advanced file search

**When to include:**

- Agents managing complex file structures
- Agents performing migrations
- Agents analyzing project structure

**When to exclude:**

- Most operational agents (use execute/\* instead)
- Agents focused on single-file operations

### Domain-Specific Tools

#### Kubernetes

```yaml
tools:
  - kubernetes/* # All Kubernetes operations
```

**Example subset:**

```yaml
tools:
  - kubernetes/get # Read cluster state
  - kubernetes/apply # Create/update resources
  - kubernetes/delete # Remove resources
  # kubernetes/* for full access
```

#### Terraform

```yaml
tools:
  - terraform/* # All Terraform operations
```

**Example subset:**

```yaml
tools:
  - terraform/plan # Generate plans
  - terraform/apply # Apply changes
  - terraform/state # Manage state
  # terraform/* for full access
```

#### GitHub (via MCP)

```yaml
tools:
  - github-mcp/* # All GitHub operations
```

**Common subsets:**

```yaml
# Read-only GitHub access
tools:
  - github-mcp/get_*
  - github-mcp/list_*
  - github-mcp/search_*

# Full GitHub access (includes write)
tools:
  - github-mcp/*
```

#### Playwright (Web Automation)

```yaml
tools:
  - playwright/* # Browser automation
```

**When to include:**

- Agents testing web applications
- Agents scraping web content
- Agents automating browser tasks

## Tool Configuration Patterns

### Pattern 1: Operational Agent (Full Access)

**Use case:** Agents that execute infrastructure operations

```yaml
---
description: Expert Kubernetes agent for safe cluster management.
tools: [execute/*, read/readFile, edit/*, search, web, kubernetes/*, agent, todo]
---
```

**Characteristics:**

- Execute to run kubectl/CLI tools
- Edit to manage manifests
- Domain-specific tools (kubernetes/\*)
- Strong guardrails in agent body

### Pattern 2: Development Agent (Code-Focused)

**Use case:** Agents implementing code changes

```yaml
---
description: Expert development orchestrator for OpenSpec implementation.
tools: [execute/*, read/readFile, edit/*, search, web, filesystem/*, github-mcp/*, agent, todo]
---
```

**Characteristics:**

- Edit for code modification
- Execute for tests/builds
- GitHub integration for PR/issue management
- Filesystem for project structure analysis

### Pattern 3: Advisory Agent (Read + Analysis)

**Use case:** Consultants, reviewers, strategists

```yaml
---
description: Senior cloud consultant for technical design and architecture.
tools: [read/readFile, search, web, edit/*, filesystem/*, agent, todo]
---
```

**Characteristics:**

- NO execute (cannot run operations)
- Edit for creating documents/proposals
- Web for research
- Focus on recommendations, not execution

### Pattern 4: Triage Agent (Investigation-Focused)

**Use case:** Debugging, analysis, investigation

```yaml
---
description: Kubernetes troubleshooting specialist for root cause analysis.
tools: [execute/*, read/readFile, search, web, kubernetes/*, agent, todo]
---
```

**Characteristics:**

- Execute to gather diagnostic info
- NO edit (read-only investigation)
- Domain-specific tools for inspection
- Recommendations only, no fixes

## Tool Selection Checklist

When configuring tools for an agent, ask:

- [ ] **Can this agent accomplish its core responsibilities with these tools?**
- [ ] **Does this agent need execution capability, or is it advisory?**
- [ ] **Should this agent create/modify files, or only read them?**
- [ ] **Does this agent need external knowledge (web access)?**
- [ ] **What domain-specific tools are required?**
- [ ] **Are there tools granted that could be removed?**
- [ ] **Do the guardrails match the tool permissions?**

## Safety Considerations

### High-Risk Tool Combinations

**execute/\* + powerful domain tools** (kubernetes/_, terraform/_)

- ⚠️ High risk: Can modify production systems
- ✅ Mitigate with: Strong confirmation requirements, dry-run validation, safety checklists

**edit/_ + execute/_**

- ⚠️ Medium risk: Can modify code and run it
- ✅ Mitigate with: Test sandbox requirements, review gates

**github-mcp/_ + execute/_**

- ⚠️ Medium risk: Can create PRs and trigger CI/CD
- ✅ Mitigate with: Branch protection requirements, explicit PR policies

### Guardrail Alignment

Tools and guardrails must align:

```yaml
# Agent with execute/* and kubernetes/*
tools: [execute/*, kubernetes/*]
```

**Must include guardrails like:**

```markdown
- Never execute on production clusters without confirmation
- Always verify cluster context before operations
- Never delete namespaces without explicit approval
```

**Mismatch example (WRONG):**

```yaml
# Advisory agent with risky tools
tools: [read/readFile, search, execute/*, terraform/*]
```

❌ Advisory agents should not have execute/\it

- ✅ Mitigate with: Test sandbox requirements, review gates

**github-mcp/_ + execute/_**

- ⚠️ Medium risk: Can create PRs and trigger CI/CD
- ✅ Mitigate with: Branch protection requirements, explicit PR policies

### Guardrail Alignment

Tools and guardrails must align:

```yaml
# Agent with execute/* and kubernetes/*
tools: [execute/*, kubernetes/*]
```

**Must include guardrails like:**

```markdown
- Never execute on production clusters without confirmation
- Always verify cluster context before operations
- Never delete namespaces without explicit approval
```

**Mismatch example (WRONG):**

```yaml
# Advisory agent with risky tools
tools: [read/readFile, search, execute/*, terraform/*]
```

❌ Advisory agents should not have execute/\* or domain operation tools.

## Common Mistakes

### ❌ Over-Permissive Tools

```yaml
# WRONG: Blanket permissions
tools: [*]  # DO NOT DO THIS

# BETTER: Specific categories
tools: [execute/*, edit/*, read/readFile, search]
```

### ❌ Insufficient Tools

```yaml
# WRONG: Terraform agent without execute
tools: [terraform/*, read/readFile]

# BETTER: Add execute for terraform CLI
tools: [execute/*, terraform/*, read/readFile]
```

### ❌ Redundant Tools

```yaml
# WRONG: Mixing MCP and execute for same operations
tools: [execute/*, kubernetes/*, read/readFile]
# If kubernetes/* provides sufficient access, this might be redundant

# BETTER: Choose primary tool path
tools: [execute/*, read/readFile]  # Use kubectl via execute
# OR
tools: [kubernetes/*, read/readFile]  # Use MCP directly
```

### ❌ Tools Without Guardrails

```yaml
# WRONG: Powerful tools without safety
tools: [execute/*, terraform/*]
# But agent has no confirmation requirements or validation gates

# BETTER: Match tools to guardrails
tools: [execute/*, terraform/*]
# Agent body includes:
# - Never apply without confirmation
# - Always run terraform plan first
# - Validate security impact before changes
```

## Tool Evolution

As agents mature, tool configurations may need adjustment:

1. **Start Conservative** — Begin with minimal tools
2. **Add Based on Need** — Expand only when limitations appear
3. **Review Periodically** — Remove unused tools
4. **Document Changes** — Track why tools were added/removed

---

**Key Takeaway:** Tool configuration is security configuration. Grant minimum necessary permissions, enforce with guardrails, and review regularly.
