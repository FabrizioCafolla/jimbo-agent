# cli-init-command Specification

## Purpose
TBD - created by archiving change implement-init-cli. Update Purpose after archive.
## Requirements
### Requirement: CLI accepts init command

The CLI MUST accept an `init` command as its first positional argument.

#### Scenario: User invokes init command

- **WHEN** user runs `cli.sh init`
- **THEN** the init command handler is executed

### Requirement: Platform flag is required

The init command MUST accept a `--platform` or `-p` flag specifying the target platform.

#### Scenario: User provides platform flag with long form

- **WHEN** user runs `cli.sh init --platform copilot`
- **THEN** the CLI processes initialization for the copilot platform

#### Scenario: User provides platform flag with short form

- **WHEN** user runs `cli.sh init -p copilot`
- **THEN** the CLI processes initialization for the copilot platform

#### Scenario: User runs init without platform flag

- **WHEN** user runs `cli.sh init` without platform flag
- **THEN** the CLI SHALL display an error message indicating platform is required
- **THEN** the CLI SHALL exit with non-zero status code

### Requirement: Only copilot platform is supported

The init command MUST only accept `copilot` as a valid platform value.

#### Scenario: User specifies copilot platform

- **WHEN** user runs `cli.sh init --platform copilot`
- **THEN** the CLI proceeds with copilot platform initialization

#### Scenario: User specifies unsupported platform

- **WHEN** user runs `cli.sh init --platform unsupported`
- **THEN** the CLI SHALL display an error message listing valid platforms
- **THEN** the CLI SHALL exit with non-zero status code

### Requirement: Framework files are copied to target directories

The init command MUST copy framework files from the source structure to appropriate target directories.

#### Scenario: All required files are copied

- **WHEN** init command executes successfully
- **THEN** the CLI SHALL copy agent configurations to `.github/agents/`
- **THEN** the CLI SHALL copy instructions to `.github/instructions/`
- **THEN** the CLI SHALL copy prompts to `.github/prompts/`
- **THEN** the CLI SHALL copy skills to `.github/skills/`

### Requirement: AGENTS.md and CONSTITUTION.md are skipped if they exist

The init command MUST NOT overwrite existing AGENTS.md or CONSTITUTION.md files in the repository root.

#### Scenario: AGENTS.md exists in target repository

- **WHEN** AGENTS.md already exists at repository root
- **THEN** the CLI SHALL skip copying AGENTS.md
- **THEN** the CLI SHALL display informative message that file was skipped

#### Scenario: CONSTITUTION.md exists in target repository

- **WHEN** CONSTITUTION.md already exists at repository root
- **THEN** the CLI SHALL skip copying CONSTITUTION.md
- **THEN** the CLI SHALL display informative message that file was skipped

#### Scenario: Neither AGENTS.md nor CONSTITUTION.md exist

- **WHEN** neither file exists at repository root
- **THEN** the CLI SHALL copy both files to repository root

### Requirement: Informative messages are displayed during execution

The init command MUST provide clear feedback about operations being performed.

#### Scenario: Operations are reported to user

- **WHEN** init command executes
- **THEN** the CLI SHALL display messages indicating which files are being copied
- **THEN** the CLI SHALL display messages when files are skipped
- **THEN** the CLI SHALL display success message upon completion

### Requirement: Errors are handled with clear messages

The init command MUST provide user-friendly error messages when operations fail.

#### Scenario: Copy operation fails

- **WHEN** a file copy operation fails
- **THEN** the CLI SHALL display an error message indicating which file failed
- **THEN** the CLI SHALL display the reason for failure if available
- **THEN** the CLI SHALL exit with non-zero status code

#### Scenario: Target directory cannot be created

- **WHEN** a required directory cannot be created
- **THEN** the CLI SHALL display an error message indicating which directory failed
- **THEN** the CLI SHALL exit with non-zero status code

