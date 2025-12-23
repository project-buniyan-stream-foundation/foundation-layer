#!/bin/bash
# Unit Tests: Tier 4 Management Layer
# Tests: Portainer
# Category: Unit Test
# Tier: 4

set -e

TEST_NAME="Tier 4 Management - Unit Tests"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Portainer Tests
test_portainer_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-portainer$"; then
        pass "Portainer container is running"
    else
        fail "Portainer container is not running"
    fi
}

test_portainer_socket() {
    local mounts=$(docker inspect foundation-portainer --format='{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}')
    if echo "$mounts" | grep -q "docker.sock"; then
        pass "Portainer Docker socket mounted"
    else
        fail "Portainer Docker socket not mounted"
    fi
}

test_portainer_volume() {
    local volumes=$(docker inspect foundation-portainer --format='{{range .Mounts}}{{.Destination}}{{"\n"}}{{end}}')
    if echo "$volumes" | grep -q "/data"; then
        pass "Portainer data volume mounted"
    else
        fail "Portainer data volume not mounted"
    fi
}

test_portainer_network() {
    local network=$(docker inspect foundation-portainer --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    if [[ "$network" == *"foundation-layer-network"* ]]; then
        pass "Portainer on foundation-layer-network"
    else
        fail "Portainer network: $network"
    fi
}

test_portainer_labels() {
    local traefik=$(docker inspect foundation-portainer --format='{{index .Config.Labels "traefik.enable"}}' 2>/dev/null || echo "false")
    if [ "$traefik" = "true" ]; then
        pass "Portainer Traefik labels configured"
    else
        fail "Portainer Traefik labels not configured"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_portainer_running
test_portainer_socket
test_portainer_volume
test_portainer_network
test_portainer_labels
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
