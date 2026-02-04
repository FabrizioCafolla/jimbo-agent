# AGENTS.md

AI-powered development assistant with specialized skills for infrastructure and software development.

## Overview

Jimbo is a collection of AI agents and skills designed to assist developers with:

- **Infrastructure Operations** — Kubernetes and Terraform workflows
- **Spec-Driven Development** — OpenSpec workflow for structured changes
- **Skill Generation** — Create reusable AI capabilities

## Structure

```
.github/
├── agents/          # Specialized agent configurations
├── instructions/    # Global behavior rules
├── prompts/         # Reusable prompt templates
└── skills/          # Domain-specific capabilities
.vscode/             #
openspec/            # Spec-driven change management
scripts/             #
```

## Agents

Specialized AI configurations for domain-specific tasks. Each agent has tailored instructions, context, and behaviors for its domain. Use agents when you need focused expertise on a particular area (e.g., Kubernetes operations, Terraform provisioning).

## Skills

Reusable capabilities that agents can invoke. Skills encapsulate domain knowledge, workflows, and best practices into discrete, composable units. They enable consistent behavior across different agents and can be combined for complex tasks.

## Governance

All agents must comply with:

- [CONSTITUTION.md](CONSTITUTION.md) — Core principles are mandatory rules
- [BRAND_GUIDELINES.md](BRAND_GUIDELINES.md) — (Optional) Defines the agent's persona, tone, and communication style
- [CODE_GUIDELINES.md](CODE_GUIDELINES.md) — (Optional) Specifies coding standards and architectural patterns
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — (Optional) Outlines ethical behavior and community standards
- [CONTRIBUTING.md](CONTRIBUTING.md) — (Optional) Guide for contributing changes to the agent system
- [README.md](README.md) — (Optional) General project documentation and entry point

### Enforcement

- If a request violates any rule in AGENTS.md or CONSTITUTION.md, you MUST refuse and explain which rule would be violated
- If the files are empty or missing, proceed with caution and apply general best practices
- Always act in accordance with the spirit of the rules, not just the letter

### Transparency

- When declining a request due to guardrail violations, clearly state which document and rule is being enforced
- Suggest compliant alternatives when possible
