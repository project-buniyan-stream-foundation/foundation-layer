#!/bin/bash
# deploy-all-tiers.sh
# Deploy all foundation tiers (restored service group structure)
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

# Load common .env file
if [ -f "$CODEBASE_ROOT/.env" ]; then
    set -a
    source "$CODEBASE_ROOT/.env"
    set +a
    echo "✅ Loaded common .env file"
fi

# Load foundation config (for backward compatibility)
if [ -f "$CODEBASE_ROOT/.foundation-config" ]; then
    source "$CODEBASE_ROOT/.foundation-config"
    export PORTFOLIO_NAME LAYER_NAME PROJECT_NAME NETWORK_NAME
fi

# Set defaults
DOCKER_STORAGE_ROOT="${DOCKER_STORAGE_ROOT:-/docker-storage}"

echo "🚀 Deploying All Foundation Tiers"
echo "===================================="
echo ""
echo "Storage Root: $DOCKER_STORAGE_ROOT"
echo "Codebase Root: $CODEBASE_ROOT"
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

echo "✅ Prerequisites met"
echo ""

# Create network
echo "🌐 Creating foundation-layer-network..."
if ! docker network inspect foundation-layer-network &> /dev/null; then
    docker network create foundation-layer-network
    echo "✅ Network created"
else
    echo "✅ Network already exists"
fi
echo ""

# Function to deploy a tier
deploy_tier() {
    local tier_name=$1
    local tier_dir="${CODEBASE_ROOT}/${tier_name}"
    
    if [ ! -d "$tier_dir" ]; then
        echo "⚠️  Tier directory not found: $tier_dir"
        return 1
    fi
    
    if [ ! -f "$tier_dir/docker-compose.yml" ]; then
        echo "⚠️  No docker-compose.yml found in: $tier_dir"
        return 1
    fi
    
    echo "📦 Deploying: $tier_name"
    cd "$tier_dir"
    
    # Load tier-specific .env file (overrides common .env)
    if [ -f ".env" ]; then
        set -a
        source ".env"
        set +a
        echo "  ✅ Loaded tier-specific .env file"
    fi
    
    export DOCKER_STORAGE_ROOT
    export PORTFOLIO_NAME LAYER_NAME PROJECT_NAME NETWORK_NAME
    
    if command -v docker compose &> /dev/null; then
        docker compose up -d
    else
        docker-compose up -d
    fi
    
    echo "✅ $tier_name deployed"
    echo ""
}

# Deploy all tiers in order
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Tier 1: Security"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier1-security"

echo "⏳ Waiting for Tier 1 services to stabilize..."
sleep 15
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Tier 2: Proxy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier2-proxy"

echo "⏳ Waiting for Traefik to stabilize..."
sleep 10
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Tier 3: Registry"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier3-registry"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Tier 4: Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier4-management"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Tier 5: Observability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier5-observability"

echo "⏳ Waiting for observability services to stabilize..."
sleep 15
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Tier 6: AI-MCP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_tier "tier6-ai-mcp"

echo "⏳ Final stabilization wait..."
sleep 10
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Deployment Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Container Statistics:"
RUNNING=$(docker ps --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --format "{{.Names}}" | wc -l)
echo "  Running: $RUNNING containers"
echo ""
echo "Service Groups:"
docker ps --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --format "{{.Label \"com.docker.compose.project\"}}" | sort -u | while read project; do
    if [ -n "$project" ]; then
        count=$(docker ps --filter "label=com.docker.compose.project=$project" -q | wc -l)
        echo "  - $project: $count container(s)"
    fi
done
echo ""
echo "All Containers:"
docker ps --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --format "  - {{.Names}}: {{.Status}}" | sort
echo ""
echo "✨ Deployment Complete!"
echo ""
