#!/bin/bash
# Batch Validation Script
# Validates all foundation layer components and generates status report

set -e

PASSED=0
FAILED=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅${NC} $1"; ((PASSED++)); }
fail() { echo -e "${RED}❌${NC} $1"; ((FAILED++)); }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; }

echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║              Foundation Layer - Batch Validation                              ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# BATCH 1: Container Status
echo "━━━ BATCH 1: Container Status ━━━"
CONTAINERS=("foundation-postgres" "foundation-vault" "foundation-keycloak" "foundation-traefik" "foundation-tier3-registry" "foundation-verdaccio" "foundation-portainer" "foundation-prometheus" "foundation-grafana" "foundation-loki" "foundation-promtail" "foundation-cadvisor" "foundation-mcp-gateway")

for container in "${CONTAINERS[@]}"; do
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        health=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-healthcheck")
        if [ "$health" = "healthy" ]; then
            pass "$container: running and healthy"
        elif [ "$health" = "no-healthcheck" ]; then
            pass "$container: running (no healthcheck)"
        else
            fail "$container: running but health=$health"
        fi
    else
        fail "$container: not running"
    fi
done
echo ""

# BATCH 2: Network Configuration
echo "━━━ BATCH 2: Network Configuration ━━━"
if docker network inspect foundation-layer-network &>/dev/null; then
    count=$(docker network inspect foundation-layer-network --format '{{len .Containers}}')
    pass "foundation-layer-network exists with $count containers"
else
    fail "foundation-layer-network does not exist"
fi
echo ""

# BATCH 3: Environment Variables (Sample)
echo "━━━ BATCH 3: Environment Variables ━━━"
if docker exec foundation-postgres printenv POSTGRES_DB 2>/dev/null | grep -q "keycloak"; then
    pass "PostgreSQL: POSTGRES_DB=keycloak"
else
    fail "PostgreSQL: POSTGRES_DB not set correctly"
fi

if docker exec foundation-postgres printenv DOCKER_STORAGE_ROOT 2>/dev/null | grep -q "/docker-storage"; then
    pass "PostgreSQL: DOCKER_STORAGE_ROOT loaded from common .env"
else
    fail "PostgreSQL: DOCKER_STORAGE_ROOT not loaded"
fi
echo ""

# BATCH 4: Traefik Labels & Service Discovery
echo "━━━ BATCH 4: Traefik Labels ━━━"
for container in foundation-vault foundation-keycloak foundation-grafana foundation-portainer; do
    local enabled=$(docker inspect "$container" --format='{{index .Config.Labels "traefik.enable"}}' 2>/dev/null || echo "false")
    if [ "$enabled" = "true" ]; then
        pass "$container: traefik.enable=true"
    else
        fail "$container: traefik.enable not set"
    fi
done
echo ""

# BATCH 5: Prometheus Labels
echo "━━━ BATCH 5: Prometheus Labels ━━━"
for container in foundation-postgres foundation-vault foundation-keycloak foundation-traefik; do
    local scrape=$(docker inspect "$container" --format='{{index .Config.Labels "prometheus.io/scrape"}}' 2>/dev/null || echo "false")
    if [ "$scrape" = "true" ]; then
        pass "$container: prometheus.io/scrape=true"
    else
        fail "$container: prometheus.io/scrape not set"
    fi
done
echo ""

# BATCH 6: Health Endpoints
echo "━━━ BATCH 6: Health Endpoints ━━━"
if docker exec foundation-traefik wget -qO- http://localhost:80/ping 2>/dev/null | grep -q "OK"; then
    pass "Traefik: /ping endpoint responds"
else
    fail "Traefik: /ping endpoint not responding"
fi

if docker exec foundation-vault wget -qO- http://localhost:8200/v1/sys/health 2>/dev/null | grep -q "initialized"; then
    pass "Vault: /v1/sys/health endpoint responds"
else
    fail "Vault: /v1/sys/health endpoint not responding"
fi

if docker exec foundation-prometheus wget -qO- http://localhost:9090/-/healthy 2>/dev/null; then
    pass "Prometheus: /-/healthy endpoint responds"
else
    fail "Prometheus: /-/healthy endpoint not responding"
fi

if docker exec foundation-grafana wget -qO- http://localhost:3000/api/health 2>/dev/null | grep -q "database"; then
    pass "Grafana: /api/health endpoint responds"
else
    fail "Grafana: /api/health endpoint not responding"
fi

if docker exec foundation-loki wget -qO- http://localhost:3100/ready 2>/dev/null | grep -q "ready"; then
    pass "Loki: /ready endpoint responds"
else
    fail "Loki: /ready endpoint not responding"
fi

if docker exec foundation-mcp-gateway wget -qO- http://localhost:8811/health 2>/dev/null; then
    pass "MCP Gateway: /health endpoint responds"
else
    fail "MCP Gateway: /health endpoint not responding"
fi
echo ""

# BATCH 7: Volume Mounts
echo "━━━ BATCH 7: Volume Mounts ━━━"
if docker inspect foundation-postgres --format='{{range .Mounts}}{{.Destination}}{{"\n"}}{{end}}' | grep -q "/var/lib/postgresql/data"; then
    pass "PostgreSQL: data volume mounted"
else
    fail "PostgreSQL: data volume not mounted"
fi

if docker inspect foundation-vault --format='{{range .Mounts}}{{.Destination}}{{"\n"}}{{end}}' | grep -q "/vault/data"; then
    pass "Vault: data volume mounted"
else
    fail "Vault: data volume not mounted"
fi

if docker inspect foundation-grafana --format='{{range .Mounts}}{{.Destination}}{{"\n"}}{{end}}' | grep -q "/var/lib/grafana"; then
    pass "Grafana: data volume mounted"
else
    fail "Grafana: data volume not mounted"
fi
echo ""

# BATCH 8: Service Groups
echo "━━━ BATCH 8: Service Groups ━━━"
groups=$(docker ps --filter "label=portfolio=portfolio-bunyan" --format "{{.Label \"com.docker.compose.project\"}}" | sort -u)
if echo "$groups" | grep -q "foundation-tier1-security"; then
    pass "Service group: foundation-tier1-security exists"
else
    fail "Service group: foundation-tier1-security not found"
fi

if echo "$groups" | grep -q "foundation-tier2-proxy"; then
    pass "Service group: foundation-tier2-proxy exists"
else
    fail "Service group: foundation-tier2-proxy not found"
fi

if echo "$groups" | grep -q "foundation-tier5-observability"; then
    pass "Service group: foundation-tier5-observability exists"
else
    fail "Service group: foundation-tier5-observability not found"
fi
echo ""

# Summary
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                          Validation Summary                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Total Tests: $((PASSED + FAILED))"
echo "  ✅ Passed: $PASSED"
echo "  ❌ Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✨ All validations passed!"
    exit 0
else
    echo "⚠️  Some validations failed"
    exit 1
fi
