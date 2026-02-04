## 1. Setup and Command Infrastructure

- [x] 1.1 Add bash shebang and set strict error handling (set -e, set -u)
- [x] 1.2 Define global constants for source and target directories
- [x] 1.3 Create command dispatcher function that routes to subcommands

## 2. Help System Implementation

- [x] 2.1 Implement show_usage() function for main help output
- [x] 2.2 Implement show_init_help() function for init command help
- [x] 2.3 Implement help command handler that calls show_usage()
- [x] 2.4 Add --help flag detection in init command

## 3. Init Command - Argument Parsing

- [x] 3.1 Implement parse_init_args() function to extract platform flag
- [x] 3.2 Validate platform flag is provided (error if missing)
- [x] 3.3 Validate platform value is 'copilot' (error if not)
- [x] 3.4 Support both --platform and -p flag formats

## 4. Init Command - File Operations

- [x] 4.1 Implement check_file_exists() helper function
- [x] 4.2 Implement copy_directory() function with error handling
- [x] 4.3 Implement copy_file_if_not_exists() for conditional copying
- [x] 4.4 Create copy_framework_files() function for main copy logic

## 5. Init Command - Platform-Specific Logic

- [x] 5.1 Implement init_copilot() function that orchestrates copilot setup
- [x] 5.2 Copy .github/agents/ directory to target
- [x] 5.3 Copy .github/instructions/ directory to target
- [x] 5.4 Copy .github/prompts/ directory to target
- [x] 5.5 Copy .github/skills/ directory to target
- [x] 5.6 Conditionally copy AGENTS.md (skip if exists)
- [x] 5.7 Conditionally copy CONSTITUTION.md (skip if exists)

## 6. Output and Error Handling

- [x] 6.1 Add echo messages for each copy operation
- [x] 6.2 Add echo messages when files are skipped
- [x] 6.3 Implement error messages for invalid platform
- [x] 6.4 Implement error messages for missing platform flag
- [x] 6.5 Implement error messages for copy failures
- [x] 6.6 Add success message when init completes
- [x] 6.7 Ensure all error messages include exit with non-zero code

## 7. Main Entry Point

- [x] 7.1 Implement main() function that parses first argument as command
- [x] 7.2 Handle 'help' command routing
- [x] 7.3 Handle 'init' command routing
- [x] 7.4 Handle unknown command with error and help suggestion
- [x] 7.5 Call main with all script arguments

## 8. Testing and Validation

- [x] 8.1 Test cli.sh help output
- [x] 8.2 Test cli.sh init --help output
- [x] 8.3 Test cli.sh init without platform flag (error case)
- [x] 8.4 Test cli.sh init with invalid platform (error case)
- [x] 8.5 Test cli.sh init --platform copilot on clean directory
- [x] 8.6 Test cli.sh init -p copilot with existing AGENTS.md (skip case)
- [x] 8.7 Test cli.sh init with existing CONSTITUTION.md (skip case)
- [x] 8.8 Verify no emoji in any output messages
