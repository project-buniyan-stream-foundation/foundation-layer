#!/bin/bash
# Unit Tests: Tier 6 AI-MCP Layer
# Tests: MCP Gateway
# Category: Unit Test
# Tier: 6

set -e

TEST_NAME="Tier 6 AI-MCP - Unit Tests"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# MCP Gateway Tests
test_mcp_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-mcp-gateway$"; then
        pass "MCP Gateway container is running"
    else
        fail "MCP Gateway container is not running"
    fi
}

test_mcp_healthy() {
    local health=$(docker inspect foundation-mcp-gateway --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "MCP Gateway container is healthy"
    else
        fail "MCP Gateway health: $health"
    fi
}

test_mcp_socket() {
    local mounts=$(docker inspect foundation-mcp-gateway --format='{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}')
    if echo "$mounts" | grep -q "docker.sock"; then
        pass "MCP Gateway Docker socket mounted"
    else
        fail "MCP Gateway Docker socket not mounted"
    fi
}

test_mcp_config() {
    if docker exec foundation-mcp-gateway test -f /app/mcp-gateway-config.yaml 2>/dev/null; then
        pass "MCP Gateway config file mounted"
    else
        fail "MCP Gateway config file not found"
    fi
}

test_mcp_network() {
    local network=$(docker inspect foundation-mcp-gateway --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    if [[ "$network" == *"foundation-layer-network"* ]]; then
        pass "MCP Gateway on foundation-layer-network"
    else
        fail "MCP Gateway network: $network"
    fi
}

test_mcp_labels() {
    local traefik=$(docker inspect foundation-mcp-gateway --format='{{index .Config.Labels "traefik.enable"}}' 2>/dev/null || echo "false")
    if [ "$traefik" = "true" ]; then
        pass "MCP Gateway Traefik labels configured"
    else
        fail "MCP Gateway Traefik labels not configured"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_mcp_running
test_mcp_healthy
test_mcp_socket
test_mcp_config
test_mcp_network
test_mcp_labels
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
