#!/bin/bash
# purge-all-containers.sh
# Purge all foundation containers, networks, and volumes (preserve images)
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
PROJECT_NAME="${PROJECT_NAME:-stream-foundation}"
NETWORK_NAME="${NETWORK_NAME:-foundation-layer-network}"

echo "🗑️  Purging All Foundation Resources"
echo "======================================"
echo ""
echo "This will remove:"
echo "  ✅ Foundation containers"
echo "  ✅ Foundation networks"
echo "  ✅ Foundation volumes"
echo ""
echo "⚠️  This will NOT remove:"
echo "  ✅ Docker images (preserved)"
echo ""

# Auto-confirm if FORCE_PURGE is set
if [ "${FORCE_PURGE:-false}" != "true" ]; then
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "❌ Purge cancelled."
        exit 0
    fi
fi

echo ""

# Step 1: Stop and remove containers
echo "🛑 Step 1: Stopping and removing containers..."
CONTAINERS=$(docker ps -aq --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --filter "label=project=${PROJECT_NAME}" 2>/dev/null | tr '\n' ' ' || true)

if [ -n "$CONTAINERS" ]; then
    CONTAINER_COUNT=$(echo "$CONTAINERS" | tr ' ' '\n' | grep -v '^$' | wc -l)
    echo "  Found $CONTAINER_COUNT container(s)"
    
    # Stop running containers
    RUNNING=$(docker ps -q --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --filter "label=project=${PROJECT_NAME}" 2>/dev/null | tr '\n' ' ' || true)
    if [ -n "$RUNNING" ]; then
        echo "  Stopping containers..."
        docker stop $RUNNING 2>/dev/null || true
    fi
    
    # Remove containers
    echo "  Removing containers..."
    docker rm $CONTAINERS 2>/dev/null || true
    echo "✅ Removed $CONTAINER_COUNT container(s)"
else
    echo "  No containers found"
fi
echo ""

# Step 2: Remove networks
echo "🌐 Step 2: Removing networks..."
NETWORKS=$(docker network ls --filter "name=${NETWORK_NAME}" --format "{{.ID}}" 2>/dev/null | tr '\n' ' ' || true)

if [ -n "$NETWORKS" ]; then
    NETWORK_COUNT=$(echo "$NETWORKS" | tr ' ' '\n' | grep -v '^$' | wc -l)
    echo "  Found $NETWORK_COUNT network(s)"
    
    for network_id in $NETWORKS; do
        network_name=$(docker network inspect "$network_id" --format "{{.Name}}" 2>/dev/null || echo "unknown")
        echo "  Removing network: $network_name"
        docker network rm "$network_id" 2>/dev/null || true
    done
    echo "✅ Removed $NETWORK_COUNT network(s)"
else
    echo "  No networks found"
fi
echo ""

# Step 3: Remove volumes
echo "💾 Step 3: Removing volumes..."
VOLUMES=$(docker volume ls --filter "name=foundation" --format "{{.Name}}" 2>/dev/null | tr '\n' ' ' || true)

if [ -n "$VOLUMES" ]; then
    VOLUME_COUNT=$(echo "$VOLUMES" | tr ' ' '\n' | grep -v '^$' | wc -l)
    echo "  Found $VOLUME_COUNT volume(s)"
    
    for volume_name in $VOLUMES; do
        echo "  Removing volume: $volume_name"
        docker volume rm "$volume_name" 2>/dev/null || true
    done
    echo "✅ Removed $VOLUME_COUNT volume(s)"
else
    echo "  No volumes found"
fi
echo ""

# Verify images are preserved
echo "🖼️  Verifying images are preserved..."
IMAGE_COUNT=$(docker images -q | wc -l)
echo "  Images preserved: $IMAGE_COUNT"
echo ""

echo "✨ Foundation resource purge complete!"
echo ""
