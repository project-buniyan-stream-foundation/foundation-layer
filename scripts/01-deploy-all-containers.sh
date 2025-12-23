#!/bin/bash
# deploy-all-containers.sh
# Deploy all foundation containers (new structure - one container per folder)
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

# Load foundation config
if [ -f "$CODEBASE_ROOT/.foundation-config" ]; then
    source "$CODEBASE_ROOT/.foundation-config"
    export PORTFOLIO_NAME LAYER_NAME PROJECT_NAME NETWORK_NAME
fi

# Set defaults
DOCKER_STORAGE_ROOT="${DOCKER_STORAGE_ROOT:-/docker-storage}"

echo "🚀 Deploying All Foundation Containers"
echo "========================================"
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

# Function to deploy a container
deploy_container() {
    local tier=$1
    local container=$2
    local container_dir="${CODEBASE_ROOT}/${tier}/${container}"
    
    if [ ! -d "$container_dir" ]; then
        echo "⚠️  Container directory not found: $container_dir"
        return 1
    fi
    
    if [ ! -f "$container_dir/docker-compose.yml" ]; then
        echo "⚠️  No docker-compose.yml found in: $container_dir"
        return 1
    fi
    
    echo "📦 Deploying: $container ($tier)"
    cd "$container_dir"
    
    export DOCKER_STORAGE_ROOT
    export PORTFOLIO_NAME LAYER_NAME PROJECT_NAME NETWORK_NAME
    
    if command -v docker compose &> /dev/null; then
        docker compose up -d
    else
        docker-compose up -d
    fi
    
    echo "✅ $container deployed"
    echo ""
}

# Deploy all containers in order
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Tier 1: Security"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier1-security" "postgres"
deploy_container "tier1-security" "vault"
deploy_container "tier1-security" "keycloak"

echo "⏳ Waiting for Tier 1 services to stabilize..."
sleep 15
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Tier 2: Proxy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier2-proxy" "traefik"

echo "⏳ Waiting for Traefik to stabilize..."
sleep 10
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Tier 3: Registry"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier3-registry" "docker-registry"
deploy_container "tier3-registry" "verdaccio"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Tier 4: Management"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier4-management" "portainer"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Tier 5: Observability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier5-observability" "prometheus"
deploy_container "tier5-observability" "grafana"
deploy_container "tier5-observability" "loki"
deploy_container "tier5-observability" "promtail"
deploy_container "tier5-observability" "cadvisor"

echo "⏳ Waiting for observability services to stabilize..."
sleep 15
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Tier 6: AI-MCP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
deploy_container "tier6-ai-mcp" "mcp-gateway"

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
echo "All Containers:"
docker ps --filter "label=portfolio=${PORTFOLIO_NAME}" --filter "label=layer=${LAYER_NAME}" --format "  - {{.Names}}: {{.Status}}" | sort
echo ""
echo "✨ Deployment Complete!"
echo ""
