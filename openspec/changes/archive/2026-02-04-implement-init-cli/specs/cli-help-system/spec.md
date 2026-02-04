## ADDED Requirements

### Requirement: CLI provides help command

The CLI MUST accept a `help` command that displays available commands.

#### Scenario: User runs help command

- **WHEN** user runs `cli.sh help`
- **THEN** the CLI SHALL display a list of all available commands
- **THEN** the CLI SHALL include brief descriptions for each command

### Requirement: Commands support help flag

Each command MUST support a `--help` flag that displays command-specific usage information.

#### Scenario: User requests help for init command

- **WHEN** user runs `cli.sh init --help`
- **THEN** the CLI SHALL display usage syntax for the init command
- **THEN** the CLI SHALL display all available flags for init command
- **THEN** the CLI SHALL display descriptions for each flag
- **THEN** the CLI SHALL display examples if applicable

### Requirement: Help output is clear and structured

Help text MUST be formatted in a clear, readable structure without decorative elements.

#### Scenario: Help text is displayed

- **WHEN** help text is shown to user
- **THEN** the output SHALL NOT contain emoji characters
- **THEN** the output SHALL use plain text formatting
- **THEN** the output SHALL be concise and easy to scan

### Requirement: Invalid commands show help suggestion

The CLI MUST suggest help command when an invalid command is provided.

#### Scenario: User provides unknown command

- **WHEN** user runs `cli.sh unknown-command`
- **THEN** the CLI SHALL display error message indicating unknown command
- **THEN** the CLI SHALL suggest running `cli.sh help` for available commands
- **THEN** the CLI SHALL exit with non-zero status code
