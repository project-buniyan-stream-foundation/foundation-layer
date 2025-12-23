#!/bin/bash
# health-check-quick.sh
# Quick health check for all foundation containers
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🏥 Foundation Layer - Quick Health Check"
echo "========================================="
echo ""

TOTAL=0
HEALTHY=0
RUNNING=0
FAILED=0

# Get all foundation containers
CONTAINERS=$(docker ps --filter "label=portfolio=portfolio-bunyan" --filter "label=layer=foundation-layer" --format "{{.Names}}" | sort)

for container in $CONTAINERS; do
    ((TOTAL++))
    health=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
    status=$(docker inspect "$container" --format='{{.State.Status}}' 2>/dev/null || echo "unknown")
    
    if [ "$health" = "healthy" ]; then
        echo "  ✅ $container - HEALTHY"
        ((HEALTHY++))
        ((RUNNING++))
    elif [ "$status" = "running" ]; then
        echo "  ⚪ $container - RUNNING"
        ((RUNNING++))
    else
        echo "  ❌ $container - $status"
        ((FAILED++))
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Health Check Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total Containers: $TOTAL"
echo "  ✅ Healthy: $HEALTHY"
echo "  ⚪ Running: $((RUNNING - HEALTHY))"
echo "  ❌ Failed: $FAILED"
echo ""

# Service Groups
echo "Service Groups:"
docker ps --filter "label=portfolio=portfolio-bunyan" --format "{{.Label \"com.docker.compose.project\"}}" | sort | uniq -c | awk '{print "  - " $2 ": " $1 " container(s)"}'
echo ""

# Network
echo "Network: foundation-layer-network"
network_count=$(docker network inspect foundation-layer-network --format '{{range .Containers}}{{.Name}}{{println}}{{end}}' 2>/dev/null | wc -l)
echo "  Containers on network: $network_count"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✨ All containers are healthy!"
    exit 0
else
    echo "⚠️  Some containers failed health check"
    exit 1
fi
