#!/bin/bash
# Unit Tests: Tier 3 Registry Layer
# Tests: Docker Registry, Verdaccio
# Category: Unit Test
# Tier: 3

set -e

TEST_NAME="Tier 3 Registry - Unit Tests"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Docker Registry Tests
test_registry_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-tier3-registry$"; then
        pass "Docker Registry container is running"
    else
        fail "Docker Registry container is not running"
    fi
}

test_registry_healthy() {
    local health=$(docker inspect foundation-tier3-registry --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "Docker Registry container is healthy"
    elif [ "$health" = "none" ]; then
        fail "Docker Registry has no healthcheck"
    else
        fail "Docker Registry health: $health"
    fi
}

test_registry_api() {
    if docker exec foundation-tier3-registry wget -qO- http://localhost:5000/v2/ 2>/dev/null | grep -q "{}"; then
        pass "Docker Registry API accessible"
    else
        fail "Docker Registry API not accessible"
    fi
}

test_registry_network() {
    local network=$(docker inspect foundation-tier3-registry --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    if [[ "$network" == *"foundation-layer-network"* ]]; then
        pass "Docker Registry on foundation-layer-network"
    else
        fail "Docker Registry network: $network"
    fi
}

# Verdaccio Tests
test_verdaccio_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-verdaccio$"; then
        pass "Verdaccio container is running"
    else
        fail "Verdaccio container is not running"
    fi
}

test_verdaccio_healthy() {
    local health=$(docker inspect foundation-verdaccio --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "Verdaccio container is healthy"
    else
        fail "Verdaccio health: $health"
    fi
}

test_verdaccio_ping() {
    if docker exec foundation-verdaccio wget -qO- http://localhost:4873/-/ping 2>/dev/null; then
        pass "Verdaccio ping endpoint accessible"
    else
        fail "Verdaccio ping endpoint not accessible"
    fi
}

test_verdaccio_network() {
    local network=$(docker inspect foundation-verdaccio --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    if [[ "$network" == *"foundation-layer-network"* ]]; then
        pass "Verdaccio on foundation-layer-network"
    else
        fail "Verdaccio network: $network"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Docker Registry Tests:"
test_registry_running
test_registry_healthy
test_registry_api
test_registry_network
echo ""

echo "Verdaccio Tests:"
test_verdaccio_running
test_verdaccio_healthy
test_verdaccio_ping
test_verdaccio_network
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
