#!/bin/bash
# Unit Tests: Tier 5 Observability Layer
# Tests: Prometheus, Grafana, Loki, Promtail, cAdvisor
# Category: Unit Test
# Tier: 5

set -e

TEST_NAME="Tier 5 Observability - Unit Tests"
PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC}: $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌ FAIL${NC}: $1"; ((FAILED++)); }

# Prometheus Tests
test_prometheus_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-prometheus$"; then
        pass "Prometheus container is running"
    else
        fail "Prometheus container is not running"
    fi
}

test_prometheus_healthy() {
    local health=$(docker inspect foundation-prometheus --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "Prometheus container is healthy"
    else
        fail "Prometheus container health: $health"
    fi
}

test_prometheus_api() {
    if docker exec foundation-prometheus wget -qO- http://localhost:9090/-/healthy 2>/dev/null | grep -q "Prometheus"; then
        pass "Prometheus API accessible"
    else
        fail "Prometheus API not accessible"
    fi
}

test_prometheus_config() {
    if docker exec foundation-prometheus test -f /etc/prometheus/prometheus.yml; then
        pass "Prometheus configuration file mounted"
    else
        fail "Prometheus configuration file not found"
    fi
}

test_prometheus_targets() {
    if docker exec foundation-prometheus wget -qO- http://localhost:9090/api/v1/targets 2>/dev/null | grep -q "activeTargets"; then
        pass "Prometheus targets endpoint accessible"
    else
        fail "Prometheus targets endpoint not accessible"
    fi
}

# Grafana Tests
test_grafana_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-grafana$"; then
        pass "Grafana container is running"
    else
        fail "Grafana container is not running"
    fi
}

test_grafana_healthy() {
    local health=$(docker inspect foundation-grafana --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "Grafana container is healthy"
    else
        fail "Grafana container health: $health"
    fi
}

test_grafana_api() {
    if docker exec foundation-grafana wget -qO- http://localhost:3000/api/health 2>/dev/null | grep -q "database"; then
        pass "Grafana API accessible"
    else
        fail "Grafana API not accessible"
    fi
}

test_grafana_datasources() {
    if docker exec foundation-grafana test -d /etc/grafana/provisioning/datasources; then
        pass "Grafana datasources directory mounted"
    else
        fail "Grafana datasources directory not found"
    fi
}

# Loki Tests
test_loki_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-loki$"; then
        pass "Loki container is running"
    else
        fail "Loki container is not running"
    fi
}

test_loki_ready() {
    if docker exec foundation-loki wget -qO- http://localhost:3100/ready 2>/dev/null | grep -q "ready"; then
        pass "Loki ready endpoint accessible"
    else
        fail "Loki ready endpoint not accessible"
    fi
}

# Promtail Tests
test_promtail_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-promtail$"; then
        pass "Promtail container is running"
    else
        fail "Promtail container is not running"
    fi
}

test_promtail_config() {
    if docker exec foundation-promtail test -f /etc/promtail/promtail-config.yaml; then
        pass "Promtail configuration file mounted"
    else
        fail "Promtail configuration file not found"
    fi
}

# cAdvisor Tests
test_cadvisor_running() {
    if docker ps --format "{{.Names}}" | grep -q "^foundation-cadvisor$"; then
        pass "cAdvisor container is running"
    else
        fail "cAdvisor container is not running"
    fi
}

test_cadvisor_healthy() {
    local health=$(docker inspect foundation-cadvisor --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    if [ "$health" = "healthy" ]; then
        pass "cAdvisor container is healthy"
    else
        fail "cAdvisor container health: $health"
    fi
}

test_cadvisor_metrics() {
    if docker exec foundation-cadvisor wget -qO- http://localhost:8080/metrics 2>/dev/null | grep -q "container_"; then
        pass "cAdvisor metrics endpoint accessible"
    else
        fail "cAdvisor metrics endpoint not accessible"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Suite: $TEST_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Prometheus Tests:"
test_prometheus_running
test_prometheus_healthy
test_prometheus_api
test_prometheus_config
test_prometheus_targets
echo ""

echo "Grafana Tests:"
test_grafana_running
test_grafana_healthy
test_grafana_api
test_grafana_datasources
echo ""

echo "Loki Tests:"
test_loki_running
test_loki_ready
echo ""

echo "Promtail Tests:"
test_promtail_running
test_promtail_config
echo ""

echo "cAdvisor Tests:"
test_cadvisor_running
test_cadvisor_healthy
test_cadvisor_metrics
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $FAILED
