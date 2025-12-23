#!/bin/bash
# Integration Test: Prometheus Metrics Scraping
# Tests: Tier 5 (Prometheus) → All Tiers metrics collection
# Category: Integration Test

set -e

TEST_NAME="Prometheus Metrics Scraping"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Test Prometheus discovers and scrapes services
test_prometheus_discovers_services() {
    local targets=$(docker exec foundation-prometheus wget -qO- http://localhost:9090/api/v1/targets 2>/dev/null)
    
    if echo "$targets" | grep -q "foundation-postgres"; then
        pass "Prometheus discovers PostgreSQL"
    else
        fail "Prometheus does not discover PostgreSQL"
    fi
    
    if echo "$targets" | grep -q "foundation-vault"; then
        pass "Prometheus discovers Vault"
    else
        fail "Prometheus does not discover Vault"
    fi
    
    if echo "$targets" | grep -q "foundation-keycloak"; then
        pass "Prometheus discovers Keycloak"
    else
        fail "Prometheus does not discover Keycloak"
    fi
    
    if echo "$targets" | grep -q "foundation-traefik"; then
        pass "Prometheus discovers Traefik"
    else
        fail "Prometheus does not discover Traefik"
    fi
    
    if echo "$targets" | grep -q "foundation-cadvisor"; then
        pass "Prometheus discovers cAdvisor"
    else
        fail "Prometheus does not discover cAdvisor"
    fi
}

test_prometheus_scrapes_metrics() {
    # Query for metrics from various services
    if docker exec foundation-prometheus wget -qO- 'http://localhost:9090/api/v1/query?query=up' 2>/dev/null | grep -q "metric"; then
        pass "Prometheus scraping metrics successfully"
    else
        fail "Prometheus not scraping metrics"
    fi
}

test_prometheus_labels_configured() {
    # Check if services have prometheus.io/scrape labels
    local postgres_label=$(docker inspect foundation-postgres --format='{{index .Config.Labels "prometheus.io/scrape"}}' 2>/dev/null || echo "false")
    local vault_label=$(docker inspect foundation-vault --format='{{index .Config.Labels "prometheus.io/scrape"}}' 2>/dev/null || echo "false")
    local keycloak_label=$(docker inspect foundation-keycloak --format='{{index .Config.Labels "prometheus.io/scrape"}}' 2>/dev/null || echo "false")
    
    if [ "$postgres_label" = "true" ] && [ "$vault_label" = "true" ] && [ "$keycloak_label" = "true" ]; then
        pass "Prometheus labels configured on Tier 1 services"
    else
        fail "Prometheus labels not configured correctly"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

test_prometheus_discovers_services
test_prometheus_scrapes_metrics
test_prometheus_labels_configured
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
