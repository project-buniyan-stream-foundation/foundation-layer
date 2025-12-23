#!/bin/bash
# stop-all-containers.sh
# Stop all foundation containers
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

# Load foundation config
if [ -f "$CODEBASE_ROOT/.foundation-config" ]; then
    source "$CODEBASE_ROOT/.foundation-config"
fi

PORTFOLIO_NAME="${PORTFOLIO_NAME:-portfolio-bunyan}"
LAYER_NAME="${LAYER_NAME:-foundation-layer}"

echo "🛑 Stopping All Foundation Containers"
echo "======================================"
echo ""

# Find and stop all foundation containers
CONTAINERS=$(docker ps -q --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" 2>/dev/null | tr '\n' ' ' || true)

if [ -n "$CONTAINERS" ]; then
    CONTAINER_COUNT=$(echo "$CONTAINERS" | tr ' ' '\n' | grep -v '^$' | wc -l)
    echo "Found $CONTAINER_COUNT container(s)"
    echo ""
    docker ps --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --format "  - {{.Names}}"
    echo ""
    echo "Stopping containers..."
    docker stop $CONTAINERS
    echo "✅ All containers stopped"
else
    echo "No running foundation containers found"
fi
echo ""
