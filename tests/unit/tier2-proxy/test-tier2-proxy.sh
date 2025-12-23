#!/bin/bash
# Unit Tests: Tier 2 Proxy Layer
# Tests: Traefik
# Category: Unit Test
# Tier: 2

set -e

TEST_NAME="Tier 2 Proxy - Unit Tests"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Traefik Tests
test_traefik_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-traefik$"; then
        pass "Traefik container is running"
    else
        fail "Traefik container is not running"
    fi
}

test_traefik_healthy() {
    local health=$(docker inspect foundation-traefik --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "Traefik container is healthy"
    else
        fail "Traefik container health: $health"
    fi
}

test_traefik_ping() {
    if docker exec foundation-traefik wget -qO- http://localhost:80/ping 2>/dev/null | grep -q "OK"; then
        pass "Traefik ping endpoint accessible"
    else
        fail "Traefik ping endpoint not accessible"
    fi
}

test_traefik_dashboard() {
    if docker exec foundation-traefik wget -qO- http://localhost:8080/api/overview 2>/dev/null | grep -q "http"; then
        pass "Traefik dashboard API accessible"
    else
        fail "Traefik dashboard API not accessible"
    fi
}

test_traefik_docker_provider() {
    if docker exec foundation-traefik wget -qO- http://localhost:8080/api/http/services 2>/dev/null | grep -q "name"; then
        pass "Traefik Docker provider discovering services"
    else
        fail "Traefik Docker provider not working"
    fi
}

test_traefik_config_file() {
    if docker exec foundation-traefik test -f /etc/traefik/traefik.yml; then
        pass "Traefik static configuration file mounted"
    else
        fail "Traefik static configuration file not found"
    fi
}

test_traefik_dynamic_config() {
    if docker exec foundation-traefik test -d /etc/traefik/dynamic; then
        pass "Traefik dynamic configuration directory mounted"
    else
        fail "Traefik dynamic configuration directory not found"
    fi
}

test_traefik_middlewares() {
    if docker exec foundation-traefik test -f /etc/traefik/dynamic/middlewares.yml; then
        pass "Traefik middlewares configuration exists"
    else
        fail "Traefik middlewares configuration not found"
    fi
}

test_traefik_prometheus_labels() {
    local prom_scrape=$(docker inspect foundation-traefik --format='{{index .Config.Labels "prometheus.io/scrape"}}' 2>/dev/null || echo "false")
    if [ "$prom_scrape" = "true" ]; then
        pass "Traefik Prometheus labels configured"
    else
        fail "Traefik Prometheus labels not configured"
    fi
}

test_traefik_network() {
    local network=$(docker inspect foundation-traefik --format='{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}')
    if [[ "$network" == *"foundation-layer-network"* ]]; then
        pass "Traefik on foundation-layer-network"
    else
        fail "Traefik network: $network"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_traefik_running
test_traefik_healthy
test_traefik_ping
test_traefik_dashboard
test_traefik_docker_provider
test_traefik_config_file
test_traefik_dynamic_config
test_traefik_middlewares
test_traefik_prometheus_labels
test_traefik_network
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
