scripts_dir := "./scripts"

# Default recipe that lists available commands
default:
    just --list

# Run the CLI
cli *args:
    {{scripts_dir}}/cli.sh {{args}}

tests *args:
    {{scripts_dir}}/tests.sh {{args}}

selfinstall:
    just cli "dev --platform copilot"
