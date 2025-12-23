#!/bin/bash
# Run All Foundation Layer Tests
# Executes unit, integration, and e2e tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                Foundation Layer - Test Suite Runner                          ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0
START_TIME=$(date +%s)

# Function to run test script
run_test_script() {
    local script=$1
    local name=$2
    
    if [ ! -f "$script" ]; then
        echo "⚠️  Test script not found: $script"
        return 1
    fi
    
    if [ ! -x "$script" ]; then
        chmod +x "$script"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if "$script"; then
        echo "✅ $name: PASSED"
        ((TOTAL_PASSED++))
    else
        echo "❌ $name: FAILED"
        ((TOTAL_FAILED++))
    fi
    echo ""
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Check if containers are running
RUNNING=$(docker ps --filter "label=portfolio=portfolio-bunyan" -q | wc -l)
if [ "$RUNNING" -lt 10 ]; then
    echo "⚠️  Warning: Only $RUNNING foundation containers running"
    echo "   Expected at least 10 containers"
    echo "   Deploy containers first: ./scripts/04-deploy-all-tiers.sh"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ Prerequisites met"
echo ""

# Run Unit Tests
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            UNIT TESTS                                         ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Tier 1
if [ -f "$TEST_ROOT/unit/tier1-security/test-tier1-security.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier1-security/test-tier1-security.sh" "Tier 1: Security"
fi

# Tier 2
if [ -f "$TEST_ROOT/unit/tier2-proxy/test-tier2-proxy.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier2-proxy/test-tier2-proxy.sh" "Tier 2: Proxy"
fi

# Tier 3
if [ -f "$TEST_ROOT/unit/tier3-registry/test-tier3-registry.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier3-registry/test-tier3-registry.sh" "Tier 3: Registry"
fi

# Tier 4
if [ -f "$TEST_ROOT/unit/tier4-management/test-tier4-management.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier4-management/test-tier4-management.sh" "Tier 4: Management"
fi

# Tier 5
if [ -f "$TEST_ROOT/unit/tier5-observability/test-tier5-observability.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier5-observability/test-tier5-observability.sh" "Tier 5: Observability"
fi

# Tier 6
if [ -f "$TEST_ROOT/unit/tier6-ai-mcp/test-tier6-ai-mcp.sh" ]; then
    run_test_script "$TEST_ROOT/unit/tier6-ai-mcp/test-tier6-ai-mcp.sh" "Tier 6: AI-MCP"
fi

# Run Integration Tests
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                         INTEGRATION TESTS                                     ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [ -d "$TEST_ROOT/integration" ]; then
    for test_script in "$TEST_ROOT/integration"/*/*.sh; do
        if [ -f "$test_script" ]; then
            test_name=$(basename "$(dirname "$test_script")")/$(basename "$test_script" .sh)
            run_test_script "$test_script" "Integration: $test_name"
        fi
    done
fi

# Run E2E Tests
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                         END-TO-END TESTS                                      ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [ -d "$TEST_ROOT/e2e" ]; then
    for test_script in "$TEST_ROOT/e2e"/*/*.sh; do
        if [ -f "$test_script" ]; then
            test_name=$(basename "$(dirname "$test_script")")/$(basename "$test_script" .sh)
            run_test_script "$test_script" "E2E: $test_name"
        fi
    done
fi

# Summary
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                            TEST SUMMARY                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests Run: $((TOTAL_PASSED + TOTAL_FAILED))"
echo "  ✅ Passed: $TOTAL_PASSED"
echo "  ❌ Failed: $TOTAL_FAILED"
echo ""
echo "Execution Time: ${DURATION}s"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "✨ All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed"
    exit 1
fi
