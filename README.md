# Jimbo Agent

> **⚠️ This project is in beta**

A comprehensive framework for structuring AI assistants in your development workflow.

## What is Jimbo Agent?

Jimbo Agent provides a standardized repository structure for organizing AI-powered development tools. It enables you to deploy specialized agents, reusable skills, and prompt templates with built-in governance rules across any AI platform (GitHub Copilot, OpenCode, Claude).

The framework follows the AGENTS and skills standards, ensuring consistent behavior and maintainability regardless of the underlying AI system.

## Why Jimbo Agent?

Modern AI assistants lack structure and consistency across projects. Jimbo Agent solves this by:

- **Standardizing AI interactions** — Uniform agent configurations and skill definitions
- **Enabling specialization** — Domain-specific agents for infrastructure, development, and operations
- **Ensuring safety** — Built-in guardrails and governance rules
- **Promoting reusability** — Skills and prompts can be shared across projects and teams
- **Supporting multiple platforms** — Works with GitHub Copilot, OpenCode, Claude, and other AI systems

## Installation

```bash
# Install in your repository
curl -fsSL https://raw.githubusercontent.com/FabrizioCafolla/jimbo-agent/main/scripts/cli.sh | bash -s -- init --platform copilot
```

This will:

- Download and set up the Jimbo Agent framework in your repository
- Create `.github/` directory with agents, instructions, prompts, and skills
- Add `AGENTS.md` and `CONSTITUTION.md` (if they don't already exist)
- Save the CLI to `.jimbo/cli.sh` for future use

Supported platforms: `copilot`

## Structure

```
.github/
├── agents/          # Specialized AI agent configurations
├── instructions/    # Global behavior rules and guardrails
├── prompts/         # Reusable prompt templates
└── skills/          # Domain-specific capabilities

openspec/            # (optional) Structured change management
├── config.yaml
├── changes/
└── specs/

AGENTS.md            # Agent documentation and standards
CONSTITUTION.md      # Core principles and governance rules
```

## Core Concepts

### Agents

Specialized AI configurations with tailored instructions for specific domains. Each agent has focused expertise.

Agents are invoked by selecting them in the Copilot chat interface.

### Skills

Reusable capabilities that encapsulate domain knowledge and workflows.
Skills run automatically when Copilot determines they are needed for the task at hand.

### Prompts

Template-based interactions for common development tasks. Prompts ensure consistent quality and reduce repetition.

Prompts are invoked using the `/jx-<name>` command in chat (e.g., `/jx-kubernetes-triage` for Kubernetes troubleshooting).

### Guardrails

Mandatory rules defined in configuration files that all agents must comply with to ensure safe, ethical, and consistent behavior:

- **CONSTITUTION.md** — Foundational principles and ethical constraints
- **AGENTS.md** — Agent-specific behaviors and standards
- **guardrails.instructions.md** — Mandatory operational rules

These files ensure AI assistants operate within defined boundaries and maintain consistent behavior across your organization.

## Usage

### Using Agents

1. Open GitHub Copilot chat in your editor
2. Select the desired agent from the agents list
3. Ask your question or describe your task

### Using Skills

Skills run automatically when GitHub Copilot determines they are necessary for your task. If you want you can also invoke them explicitly.

### Using Prompts

Invoke prompts using slash commands in the chat:

```
/jx-kubernetes-triage
/jx-<...>
```

## Integration

### VS Code

Jimbo Agent includes optimized settings for GitHub Copilot in VS Code. Configuration is applied automatically during installation.

### OpenSpec

We recommend using [OpenSpec](https://github.com/Fission-AI/OpenSpec) for structured issue and change management.

## Customization

You can add new items in your project:

- **Add new agents** — Create new agent configurations in `.github/agents/`
- **Create new skills** — Use the skill template generator
- **Define new prompts** — Add templates in `.github/prompts/`
- **(suggested) Customize AGENTS** — Modify `AGENTS.md` for your repository's policies
- **(suggested) Customize guardrails** — Modify `CONSTITUTION.md` for your repository/team's policies

## Develop

...in progress
