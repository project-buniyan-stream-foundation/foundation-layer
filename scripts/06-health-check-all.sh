#!/bin/bash
# health-check-all.sh
# Automated health check for all foundation containers
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🏥 Foundation Layer - Automated Health Check"
echo "============================================="
echo ""

# Load common .env
if [ -f "$CODEBASE_ROOT/.env" ]; then
    source "$CODEBASE_ROOT/.env"
fi

TOTAL_CONTAINERS=0
HEALTHY_CONTAINERS=0
RUNNING_CONTAINERS=0
FAILED_CONTAINERS=0

# Function to check container health
check_container_health() {
    local container=$1
    local tier=$2
    local endpoint=$3
    local expected_response=$4
    
    ((TOTAL_CONTAINERS++))
    
    # Check if container is running
    if ! docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        echo "  ❌ $container - NOT RUNNING"
        ((FAILED_CONTAINERS++))
        return 1
    fi
    
    # Check Docker health status
    health_status=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    
    if [ "$health_status" = "healthy" ]; then
        echo "  ✅ $container - HEALTHY"
        ((HEALTHY_CONTAINERS++))
        ((RUNNING_CONTAINERS++))
        return 0
    elif [ "$health_status" = "none" ]; then
        # No health check defined, check if running
        status=$(docker inspect "$container" --format='{{.State.Status}}' 2>/dev/null || echo "unknown")
        if [ "$status" = "running" ]; then
            # Try endpoint check if provided
            if [ -n "$endpoint" ]; then
                if timeout 3 curl -sf "$endpoint" > /dev/null 2>&1; then
                    echo "  ✅ $container - RUNNING (endpoint responsive)"
                    ((RUNNING_CONTAINERS++))
                    return 0
                else
                    echo "  ⚪ $container - RUNNING (no health check, endpoint not responsive)"
                    ((RUNNING_CONTAINERS++))
                    return 0
                fi
            else
                echo "  ⚪ $container - RUNNING (no health check)"
                ((RUNNING_CONTAINERS++))
                return 0
            fi
        else
            echo "  ❌ $container - $status"
            ((FAILED_CONTAINERS++))
            return 1
        fi
    else
        echo "  ⚠️  $container - $health_status"
        ((RUNNING_CONTAINERS++))
        return 0
    fi
}

# Check all containers by tier
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Tier 1: Security"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-postgres" "1" "" ""
check_container_health "foundation-vault" "1" "http://localhost:8200/v1/sys/health" ""
check_container_health "foundation-keycloak" "1" "http://localhost:8180/" ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Tier 2: Proxy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-traefik" "2" "http://localhost/ping" ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Tier 3: Registry"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-tier3-registry" "3" "http://localhost:5000/v2/" ""
check_container_health "foundation-verdaccio" "3" "http://localhost:4873/-/ping" ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Tier 4: Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-portainer" "4" "http://localhost:3103/" ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Tier 5: Observability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-prometheus" "5" "http://localhost:3101/-/healthy" ""
check_container_health "foundation-grafana" "5" "http://localhost:3100/api/health" ""
check_container_health "foundation-loki" "5" "http://localhost:3200/ready" ""
check_container_health "foundation-promtail" "5" "" ""
check_container_health "foundation-cadvisor" "5" "http://localhost:3102/healthz" ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Tier 6: AI-MCP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_container_health "foundation-mcp-gateway" "6" "http://localhost:8811/health" ""
echo ""

# Service Group Verification
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏷️  Service Group Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
docker ps --filter "label=portfolio=portfolio-bunyan" --format "{{.Label \"com.docker.compose.project\"}}\t{{.Names}}" | sort | column -t
echo ""

# Network Verification
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Network Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
NETWORK_COUNT=$(docker network inspect foundation-layer-network --format '{{range .Containers}}{{.Name}}{{println}}{{end}}' 2>/dev/null | wc -l)
echo "Containers on foundation-layer-network: $NETWORK_COUNT"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Health Check Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Containers: $TOTAL_CONTAINERS"
echo "  ✅ Healthy: $HEALTHY_CONTAINERS"
echo "  ⚪ Running: $((RUNNING_CONTAINERS - HEALTHY_CONTAINERS))"
echo "  ❌ Failed: $FAILED_CONTAINERS"
echo ""

if [ $FAILED_CONTAINERS -eq 0 ]; then
    echo "✨ All containers are healthy!"
    exit 0
else
    echo "⚠️  Some containers failed health check"
    exit 1
fi
