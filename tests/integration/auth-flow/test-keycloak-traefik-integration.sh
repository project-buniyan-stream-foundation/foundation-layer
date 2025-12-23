#!/bin/bash
# Integration Test: Keycloak-Traefik Authentication Flow
# Tests: Tier 1 (Keycloak) → Tier 2 (Traefik) integration
# Category: Integration Test

set -e

TEST_NAME="Keycloak-Traefik Integration"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Integration Tests
test_keycloak_reachable_from_traefik() {
    if docker exec foundation-traefik wget -qO- http://foundation-keycloak:8080/health/ready 2>/dev/null | grep -q "status"; then
        pass "Keycloak reachable from Traefik container"
    else
        fail "Keycloak not reachable from Traefik container"
    fi
}

test_traefik_discovers_keycloak() {
    if docker exec foundation-traefik wget -qO- http://localhost:8080/api/http/services 2>/dev/null | grep -q "keycloak"; then
        pass "Traefik discovers Keycloak service"
    else
        fail "Traefik does not discover Keycloak service"
    fi
}

test_traefik_discovers_vault() {
    if docker exec foundation-traefik wget -qO- http://localhost:8080/api/http/services 2>/dev/null | grep -q "vault"; then
        pass "Traefik discovers Vault service"
    else
        fail "Traefik does not discover Vault service"
    fi
}

test_forward_auth_middleware_configured() {
    if docker exec foundation-traefik test -f /etc/traefik/dynamic/middlewares.yml; then
        if docker exec foundation-traefik cat /etc/traefik/dynamic/middlewares.yml | grep -q "keycloak-forward-auth"; then
            pass "Keycloak forward auth middleware configured"
        else
            fail "Keycloak forward auth middleware not found in config"
        fi
    else
        fail "Middlewares configuration file not found"
    fi
}

test_traefik_labels_on_vault() {
    local router_rule=$(docker inspect foundation-vault --format='{{index .Config.Labels "traefik.http.routers.vault.rule"}}' 2>/dev/null || echo "none")
    if [[ "$router_rule" == *"Host"* ]]; then
        pass "Vault Traefik router rule configured"
    else
        fail "Vault Traefik router rule not configured: $router_rule"
    fi
}

test_traefik_labels_on_keycloak() {
    local router_rule=$(docker inspect foundation-keycloak --format='{{index .Config.Labels "traefik.http.routers.keycloak.rule"}}' 2>/dev/null || echo "none")
    if [[ "$router_rule" == *"Host"* ]]; then
        pass "Keycloak Traefik router rule configured"
    else
        fail "Keycloak Traefik router rule not configured: $router_rule"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_keycloak_reachable_from_traefik
test_traefik_discovers_keycloak
test_traefik_discovers_vault
test_forward_auth_middleware_configured
test_traefik_labels_on_vault
test_traefik_labels_on_keycloak
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
