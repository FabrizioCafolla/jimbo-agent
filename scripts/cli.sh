#!/usr/bin/env bash
set -euo pipefail

# Jimbo Agent CLI
# Installation and management tool for Jimbo Agent framework

# Global constants
readonly GITHUB_REPO="https://github.com/FabrizioCafolla/jimbo-agent"
readonly GITHUB_RAW="https://raw.githubusercontent.com/FabrizioCafolla/jimbo-agent/main"
readonly TARGET_DIR="$(pwd)"
readonly JIMBO_DIR="${TARGET_DIR}/.jimbo"
readonly TEMP_DIR=$(mktemp -d)

# Detect if running from local repository or remote
# Handle pipe execution where BASH_SOURCE may not be set
if [[ -n "${BASH_SOURCE:-}" ]] && [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
else
    readonly SCRIPT_DIR=""
fi

if [[ -n "${SCRIPT_DIR}" ]]; then
    readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." 2>/dev/null && pwd || echo "")"
else
    readonly PROJECT_ROOT=""
fi

# Cleanup function
cleanup() {
    if [[ -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
}
trap cleanup EXIT

# Help functions
show_usage() {
    cat <<EOF
Jimbo Agent CLI - Installation and management tool

USAGE:
    cli.sh <command> [options]

COMMANDS:
    help        Show this help message
    init        Initialize Jimbo Agent framework in current repository
    dev         Setup development environment with symlinks

Run 'cli.sh <command> --help' for more information on a specific command.
EOF
}

show_init_help() {
    cat <<EOF
Initialize Jimbo Agent framework

USAGE:
    cli.sh init --platform <platform>
    cli.sh init -p <platform>

OPTIONS:
    -p, --platform <platform>    Target platform (required)
                                 Supported platforms: copilot

EXAMPLES:
    cli.sh init --platform copilot
    cli.sh init -p copilot
EOF
}

show_dev_help() {
    cat <<EOF
Setup development environment with symlinks

USAGE:
    cli.sh dev --platform <platform>
    cli.sh dev -p <platform>

OPTIONS:
    -p, --platform <platform>    Target platform (required)
                                 Supported platforms: copilot

DESCRIPTION:
    Creates symbolic links from lib/ to .github/ directories.
    This allows editing files in lib/ while they are automatically
    available in the platform-specific location.

EXAMPLES:
    cli.sh dev --platform copilot
    cli.sh dev -p copilot
EOF
}

# Helper functions
check_file_exists() {
    local file="$1"
    [[ -f "${file}" ]]
}

download_file() {
    local url="$1"
    local dest="$2"
    local name="$3"

    if ! curl -fsSL "${url}" -o "${dest}"; then
        echo "Error: Failed to download ${name}"
        exit 1
    fi
}

download_repository() {
    echo "Downloading Jimbo Agent from GitHub..."

    local temp_path="${TEMP_DIR}/repo"
    mkdir -p "${temp_path}"

    # Download entire repository as tar.gz
    local archive_url="${GITHUB_REPO}/archive/refs/heads/main.tar.gz"

    if ! curl -fsSL "${archive_url}" -o "${temp_path}/repo.tar.gz"; then
        echo "Error: Failed to download repository archive"
        exit 1
    fi

    # Extract the entire repository
    if ! tar -xzf "${temp_path}/repo.tar.gz" -C "${temp_path}" --strip-components=1 2>/dev/null; then
        echo "Error: Failed to extract repository"
        exit 1
    fi

    echo "Repository downloaded successfully"
}

copy_directory() {
    local src="$1"
    local dest="$2"
    local name="$3"

    echo "Copying ${name}..."

    if [[ ! -d "${src}" ]]; then
        echo "Warning: Source directory '${src}' not found, skipping ${name}"
        return 0
    fi

    # Check if directory has meaningful content (exclude .gitkeep only)
    local file_count=$(find "${src}" -mindepth 1 ! -name '.gitkeep' | wc -l | tr -d ' ')
    if [[ "${file_count}" -eq 0 ]]; then
        echo "Warning: Source directory '${src}' is empty (only .gitkeep), skipping ${name}"
        return 0
    fi

    # Use -L to dereference symlinks (copy actual files, not symlinks)
    if ! cp -rL "${src}"/* "${dest}/" 2>/dev/null; then
        echo "Error: Failed to copy ${name}"
        exit 1
    fi
}

copy_file_if_not_exists() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if check_file_exists "${dest}"; then
        echo "Skipping ${name} (already exists)"
        return 0
    fi

    echo "Copying ${name}..."
    if ! cp "${src}" "${dest}"; then
        echo "Error: Failed to copy ${name}"
        exit 1
    fi
}

save_cli() {
    echo "Saving CLI to ${JIMBO_DIR}..."

    mkdir -p "${JIMBO_DIR}"

    local cli_dest="${JIMBO_DIR}/cli.sh"

    # If running from stdin (piped), download the script
    if [[ -z "${SCRIPT_DIR}" ]] || [[ ! -f "$0" ]]; then
        if ! curl -fsSL "${GITHUB_RAW}/scripts/cli.sh" -o "${cli_dest}"; then
            echo "Error: Failed to save CLI"
            exit 1
        fi
    else
        cp "$0" "${cli_dest}"
    fi

    chmod +x "${cli_dest}"

    echo "CLI saved to ${cli_dest}"
}

# Platform-specific initialization
init_copilot() {
    echo "Initializing Jimbo Agent for GitHub Copilot..."
    download_repository
    local repo_dir="${TEMP_DIR}/repo"
    echo ""

    local github_dir="${TARGET_DIR}/.github"
    mkdir -p "${github_dir}/agents"
    mkdir -p "${github_dir}/prompts"
    mkdir -p "${github_dir}/skills"

    copy_directory "${repo_dir}/lib/agents" "${github_dir}/agents" "agent configurations"
    copy_directory "${repo_dir}/lib/prompts" "${github_dir}/prompts" "prompt templates"
    copy_directory "${repo_dir}/lib/skills" "${github_dir}/skills" "skill definitions"

    copy_file_if_not_exists "${repo_dir}/AGENTS.md" "${TARGET_DIR}/AGENTS.md" "AGENTS.md"
    copy_file_if_not_exists "${repo_dir}/CONSTITUTION.md" "${TARGET_DIR}/CONSTITUTION.md" "CONSTITUTION.md"

    save_cli

    echo ""
    echo "Initialization complete!"
    echo "Jimbo Agent has been successfully installed for GitHub Copilot."
    echo "CLI available at: ${JIMBO_DIR}/cli.sh"
}

# Platform-specific dev setup
dev_copilot() {
    echo "Setting up development environment for GitHub Copilot..."
    echo ""

    local github_dir="${TARGET_DIR}/.github"
    local lib_dir="${TARGET_DIR}/lib"

    mkdir -p "${github_dir}/agents"
    mkdir -p "${github_dir}/prompts"
    mkdir -p "${github_dir}/skills"

    # Link agents
    echo "Linking agents..."
    for agent in "${lib_dir}"/agents/*; do
        [[ -e "${agent}" ]] || continue
        local filename=$(basename "${agent}")
        ln -sf "../../lib/agents/${filename}" "${github_dir}/agents/${filename}"
    done

    # Link prompts
    echo "Linking prompts..."
    for prompt in "${lib_dir}"/prompts/*; do
        [[ -e "${prompt}" ]] || continue
        local filename=$(basename "${prompt}")
        ln -sf "../../lib/prompts/${filename}" "${github_dir}/prompts/${filename}"
    done

    # Link skills
    echo "Linking skills..."
    for skill_dir in "${lib_dir}"/skills/*; do
        [[ -d "${skill_dir}" ]] || continue
        local skill_name=$(basename "${skill_dir}")
        mkdir -p "${github_dir}/skills/${skill_name}"
        if [[ -f "${skill_dir}/SKILL.md" ]]; then
            ln -sf "../../../lib/skills/${skill_name}/SKILL.md" "${github_dir}/skills/${skill_name}/SKILL.md"
        fi
    done

    echo ""
    echo "Development environment ready!"
    echo "Files in lib/ are now linked to .github/"
}

# Command handlers
cmd_help() {
    show_usage
}

cmd_init() {
    for arg in "$@"; do
        if [[ "${arg}" == "--help" ]]; then
            show_init_help
            exit 0
        fi
    done

    local platform=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--platform)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --platform requires a value"
                    echo "Run 'cli.sh init --help' for usage"
                    exit 1
                fi
                platform="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'"
                echo "Run 'cli.sh init --help' for usage"
                exit 1
                ;;
        esac
    done

    if [[ -z "${platform}" ]]; then
        echo "Error: --platform flag is required"
        echo "Run 'cli.sh init --help' for usage"
        exit 1
    fi

    if [[ "${platform}" != "copilot" ]]; then
        echo "Error: Unsupported platform '${platform}'"
        echo "Supported platforms: copilot"
        exit 1
    fi

    init_copilot
}

cmd_dev() {
    for arg in "$@"; do
        if [[ "${arg}" == "--help" ]]; then
            show_dev_help
            exit 0
        fi
    done

    local platform=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--platform)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: --platform requires a value"
                    echo "Run 'cli.sh dev --help' for usage"
                    exit 1
                fi
                platform="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'"
                echo "Run 'cli.sh dev --help' for usage"
                exit 1
                ;;
        esac
    done

    if [[ -z "${platform}" ]]; then
        echo "Error: --platform flag is required"
        echo "Run 'cli.sh dev --help' for usage"
        exit 1
    fi

    if [[ "${platform}" != "copilot" ]]; then
        echo "Error: Unsupported platform '${platform}'"
        echo "Supported platforms: copilot"
        exit 1
    fi

    dev_copilot
}

# Command dispatcher
dispatch_command() {
    local cmd="${1:-}"

    case "${cmd}" in
        help)
            cmd_help
            ;;
        init)
            shift
            cmd_init "$@"
            ;;
        dev)
            shift
            cmd_dev "$@"
            ;;
        "")
            echo "Error: No command provided"
            echo "Run 'cli.sh help' for usage information"
            exit 1
            ;;
        *)
            echo "Error: Unknown command '${cmd}'"
            echo "Run 'cli.sh help' for available commands"
            exit 1
            ;;
    esac
}

# Main entry point
main() {
    dispatch_command "$@"
}

main "$@"
