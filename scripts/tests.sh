#!/usr/bin/env bash
set -euo pipefail

# Jimbo Agent CLI Tests
# Test suite for the CLI functionality

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_SCRIPT="${SCRIPT_DIR}/cli.sh"
TEST_DIR="${SCRIPT_DIR}/tests/cli"

# Setup test environment
setup() {
    echo "Setting up test environment..."
    rm -rf "${TEST_DIR}"
    mkdir -p "${TEST_DIR}"
}

# Cleanup test environment
cleanup() {
    if [[ "${KEEP_TEST_FILES:-false}" == "true" ]]; then
        echo "Keeping test files in ${TEST_DIR} for inspection"
    else
        echo "Cleaning up test environment..."
        rm -rf "${TEST_DIR}"
    fi
}

# Test helper functions
assert_success() {
    local test_name="$1"
    local cmd="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if eval "${cmd}" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} ${test_name}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_failure() {
    local test_name="$1"
    local cmd="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    if eval "${cmd}" > /dev/null 2>&1; then
        echo -e "${RED}✗${NC} ${test_name} (expected failure)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    else
        echo -e "${GREEN}✓${NC} ${test_name}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi
}

assert_output_contains() {
    local test_name="$1"
    local cmd="$2"
    local expected="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    local output=$(eval "${cmd}" 2>&1 || true)

    if echo "${output}" | grep -q "${expected}"; then
        echo -e "${GREEN}✓${NC} ${test_name}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Expected output to contain: ${expected}"
        echo "  Actual output: ${output}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_no_emoji() {
    local test_name="$1"
    local cmd="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    local output=$(eval "${cmd}" 2>&1 || true)

    # Check for common emoji patterns
    if echo "${output}" | grep -qE '[\x{1F300}-\x{1F9FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]'; then
        echo -e "${RED}✗${NC} ${test_name}"
        echo "  Found emoji in output"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    else
        echo -e "${GREEN}✓${NC} ${test_name}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi
}

# Test suite
run_tests() {
    echo ""
    echo "=== Running CLI Tests ==="
    echo ""

    # Test 1: Help command
    echo "Testing help command..."
    assert_output_contains "Help command shows usage" \
        "${CLI_SCRIPT} help" \
        "Jimbo Agent CLI"

    assert_output_contains "Help shows available commands" \
        "${CLI_SCRIPT} help" \
        "COMMANDS:"

    # Test 2: Init help
    echo ""
    echo "Testing init --help..."
    assert_output_contains "Init help shows usage" \
        "${CLI_SCRIPT} init --help" \
        "Initialize Jimbo Agent framework"

    assert_output_contains "Init help shows platform option" \
        "${CLI_SCRIPT} init --help" \
        "platform"

    # Test 3: Dev help
    echo ""
    echo "Testing dev --help..."
    assert_output_contains "Dev help shows usage" \
        "${CLI_SCRIPT} dev --help" \
        "Setup development environment"

    assert_output_contains "Dev help shows platform option" \
        "${CLI_SCRIPT} dev --help" \
        "platform"

    echo ""
    echo "Testing error cases..."
    assert_failure "Init without platform fails" \
        "${CLI_SCRIPT} init"

    assert_output_contains "Init without platform shows error" \
        "${CLI_SCRIPT} init" \
        "platform flag is required"

    # Test 4: Dev without platform
    assert_failure "Dev without platform fails" \
        "${CLI_SCRIPT} dev"

    assert_output_contains "Dev without platform shows error" \
        "${CLI_SCRIPT} dev" \
        "platform flag is required"

    # Test 5: Invalid platform
    assert_failure "Init with invalid platform fails" \
        "${CLI_SCRIPT} init --platform invalid"

    assert_output_contains "Init with invalid platform shows error" \
        "${CLI_SCRIPT} init --platform invalid" \
        "Unsupported platform"

    assert_failure "Dev with invalid platform fails" \
        "${CLI_SCRIPT} dev --platform invalid"

    assert_output_contains "Dev with invalid platform shows error" \
        "${CLI_SCRIPT} dev --platform invalid" \
        "Unsupported platform"

    # Test 6: Unknown command
    assert_failure "Unknown command fails" \
        "${CLI_SCRIPT} unknown"

    assert_output_contains "Unknown command shows error" \
        "${CLI_SCRIPT} unknown" \
        "Unknown command"

    # Test 7: No emoji in output
    echo ""
    echo "Testing output formatting..."
    assert_no_emoji "Help output has no emoji" \
        "${CLI_SCRIPT} help"

    assert_no_emoji "Init help output has no emoji" \
        "${CLI_SCRIPT} init --help"

    assert_no_emoji "Dev help output has no emoji" \
        "${CLI_SCRIPT} dev --help"

    assert_no_emoji "Error messages have no emoji" \
        "${CLI_SCRIPT} init"

    # Test 8: Full init test (if not in CI or local development mode)
    echo ""
    if [[ "${SKIP_FULL_INIT:-false}" == "true" ]]; then
        echo "Testing full initialization (skipped - requires network)..."
        echo -e "${YELLOW}ℹ${NC} Set SKIP_FULL_INIT=false to run full init test"
    else
        echo "Testing full initialization..."
        cd "${TEST_DIR}"
        assert_success "Init copilot platform succeeds" \
            "${CLI_SCRIPT} init --platform copilot"

        assert_success "AGENTS.md is created" \
            "test -f ${TEST_DIR}/AGENTS.md"

        assert_success "CONSTITUTION.md is created" \
            "test -f ${TEST_DIR}/CONSTITUTION.md"

        assert_success ".github/agents directory is created" \
            "test -d ${TEST_DIR}/.github/agents"

        assert_success ".jimbo/cli.sh is created" \
            "test -f ${TEST_DIR}/.jimbo/cli.sh"
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "=== Test Summary ==="
    echo "Tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"

    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
        return 1
    else
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    fi
}

# Main
main() {
    setup
    run_tests
    local result=0
    print_summary || result=$?

    # Set KEEP_TEST_FILES=true to inspect test output
    export KEEP_TEST_FILES=true
    cleanup

    exit ${result}
}

main "$@"
