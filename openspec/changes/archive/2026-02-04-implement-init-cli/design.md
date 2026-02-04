## Context

The Jimbo Agent project currently lacks a standardized CLI for installation. The `scripts/cli.sh` file exists but is empty. Users need a way to initialize the framework in their repositories with platform-specific configurations (starting with GitHub Copilot).

The CLI must be:

- **Self-contained**: Single bash script, no external dependencies
- **Modular**: Support adding new commands beyond `init`
- **Safe**: Never overwrite critical user files (AGENTS.md, CONSTITUTION.md)
- **Clear**: Informative output without decorative elements (no emoji)

## Goals / Non-Goals

**Goals:**

- Implement clean command architecture supporting multiple subcommands
- Provide `init` command with platform selection
- Implement `help` system for discovery and usage guidance
- Handle errors with clear, actionable messages
- Skip existing AGENTS.md and CONSTITUTION.md files to preserve user customizations

**Non-Goals:**

- Interactive prompts (all input via flags)
- Configuration file generation
- Package manager integration (npm, homebrew, etc.)
- Multi-platform file detection or merging logic
- Logging to files

## Decisions

### Command Architecture: Function-based Dispatch

**Decision**: Use bash functions with a dispatch pattern rather than case statements for each command.

**Rationale**:

- Makes adding new commands trivial (just add a new function)
- Keeps help text co-located with command implementation
- Easier to test and maintain
- Follows Unix philosophy of composable functions

**Alternative considered**: Large case statement with inline logic - rejected due to poor scalability and readability.

### Platform Handling: Explicit Flag Required

**Decision**: Require `--platform` or `-p` flag for init command; no defaults.

**Rationale**:

- Makes intent explicit
- Prevents accidental initialization with wrong platform
- Easier to add new platforms without breaking changes
- Clear error messages guide users

**Alternative considered**: Auto-detect from existing configs - rejected as too implicit and error-prone.

### File Preservation: Skip Strategy

**Decision**: Check for existence of AGENTS.md and CONSTITUTION.md before copying; skip if present.

**Rationale**:

- These files are meant to be customized by users
- Preserves user work and prevents data loss
- Simple implementation with clear messaging
- Aligns with non-destructive principle

**Alternative considered**: Backup and overwrite - rejected as complex and confusing for users.

### Error Handling: Fail Fast with Context

**Decision**: Exit immediately on errors with descriptive messages and non-zero exit codes.

**Rationale**:

- Prevents cascading failures
- Makes errors easy to debug
- Compatible with CI/CD pipelines
- Clear failure points

**Alternative considered**: Continue on errors with warnings - rejected as it could leave repository in inconsistent state.

### Single File Implementation

**Decision**: Keep entire CLI in one bash script despite multiple commands.

**Rationale**:

- Simpler distribution (one file to copy)
- No path resolution complexity
- Easier for users to read and understand
- Sufficient for current scope (2-3 commands expected)

**Alternative considered**: Multi-file structure with sourcing - rejected as premature complexity.

## Risks / Trade-offs

**[Risk]**: Future commands may bloat single file making it hard to maintain
**→ Mitigation**: Refactor to multi-file structure if script exceeds ~500 lines or ~10 commands

**[Risk]**: Bash portability issues across different shells
**→ Mitigation**: Use POSIX-compatible syntax; add shebang for bash; test on macOS and Linux

**[Trade-off]**: No interactive mode means users must know exact flags
**→ Accepted**: Help system and clear error messages provide sufficient guidance

**[Trade-off]**: Skip strategy for AGENTS.md/CONSTITUTION.md means users never get updates
**→ Accepted**: These are meant to be customized; framework updates go in other files

## Migration Plan

Not applicable - this is a new feature with no existing CLI to migrate from.

## Open Questions

None - design is complete and implementation can proceed.
