## Why

The Jimbo Agent project currently lacks a standardized installation mechanism. Users need a clean, modular CLI to initialize the framework in their repositories. The CLI must support multiple platforms (starting with GitHub Copilot) and be extensible for future commands.

## What Changes

- Create a modular CLI script (`scripts/cli.sh`) with command architecture
- Implement `init` command with `--platform/-p` flag (accepts: `copilot`)
- Add `help` command for listing available commands
- Add `--help` flag for command-specific usage information
- Implement file copying logic with conditional overwrites (skip AGENTS.md and CONSTITUTION.md if they exist)
- Add informative echo messages for operations
- Implement clear, user-friendly error handling

## Capabilities

### New Capabilities

- `cli-init-command`: Initialize Jimbo Agent framework in a repository based on platform selection
- `cli-help-system`: Provide contextual help for commands and available options

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

- **New file**: `scripts/cli.sh` - Main CLI implementation
- **Dependencies**: None (pure bash)
- **Users**: Developers installing Jimbo Agent for the first time
- **Future extension point**: Command architecture supports adding new commands beyond `init`
