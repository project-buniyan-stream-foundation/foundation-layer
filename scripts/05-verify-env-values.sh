#!/bin/bash
# verify-env-values.sh
# Verify that containers loaded environment variables from both common and local .env files
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Verifying Environment Variables in Containers"
echo "================================================="
echo ""

# Load common .env for comparison
if [ -f "$CODEBASE_ROOT/.env" ]; then
    source "$CODEBASE_ROOT/.env"
fi

# Function to verify env var in container
verify_container_env() {
    local container=$1
    local var_name=$2
    local expected_value=$3
    
    if ! docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        echo "  ⚠️  Container $container not running"
        return 1
    fi
    
    actual_value=$(docker exec "$container" printenv "$var_name" 2>/dev/null || echo "NOT_SET")
    
    if [ "$actual_value" = "$expected_value" ]; then
        echo "  ✅ $var_name = $expected_value"
        return 0
    elif [ "$actual_value" = "NOT_SET" ]; then
        echo "  ❌ $var_name = NOT SET (expected: $expected_value)"
        return 1
    else
        echo "  ⚠️  $var_name = $actual_value (expected: $expected_value)"
        return 1
    fi
}

# Verify common variables across all containers
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Verifying Common Environment Variables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COMMON_VARS_PASSED=0
COMMON_VARS_FAILED=0

for container in $(docker ps --filter "label=portfolio=portfolio-bunyan" --format "{{.Names}}" | sort); do
    echo "Container: $container"
    
    # Check DOCKER_STORAGE_ROOT (common variable)
    if verify_container_env "$container" "DOCKER_STORAGE_ROOT" "$DOCKER_STORAGE_ROOT"; then
        ((COMMON_VARS_PASSED++))
    else
        ((COMMON_VARS_FAILED++))
    fi
    
    echo ""
done

# Verify tier-specific variables
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Verifying Tier-Specific Environment Variables"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TIER_VARS_PASSED=0
TIER_VARS_FAILED=0

# Tier 1 - PostgreSQL
echo "Tier 1 - PostgreSQL:"
if verify_container_env "foundation-postgres" "POSTGRES_DB" "keycloak"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
if verify_container_env "foundation-postgres" "POSTGRES_USER" "keycloak"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Tier 1 - Vault
echo "Tier 1 - Vault:"
if verify_container_env "foundation-vault" "VAULT_LOG_LEVEL" "info"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Tier 1 - Keycloak
echo "Tier 1 - Keycloak:"
if verify_container_env "foundation-keycloak" "KEYCLOAK_ADMIN" "admin"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Tier 2 - Traefik
echo "Tier 2 - Traefik:"
if verify_container_env "foundation-traefik" "TRAEFIK_LOG_LEVEL" "INFO"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Tier 5 - Grafana
echo "Tier 5 - Grafana:"
if verify_container_env "foundation-grafana" "GF_SECURITY_ADMIN_USER" "admin"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Tier 6 - MCP Gateway
echo "Tier 6 - MCP Gateway:"
if verify_container_env "foundation-mcp-gateway" "DOCKER_MCP_USE_CE" "true"; then
    ((TIER_VARS_PASSED++))
else
    ((TIER_VARS_FAILED++))
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Common Variables:"
echo "  ✅ Passed: $COMMON_VARS_PASSED"
echo "  ❌ Failed: $COMMON_VARS_FAILED"
echo ""
echo "Tier-Specific Variables:"
echo "  ✅ Passed: $TIER_VARS_PASSED"
echo "  ❌ Failed: $TIER_VARS_FAILED"
echo ""

TOTAL_PASSED=$((COMMON_VARS_PASSED + TIER_VARS_PASSED))
TOTAL_FAILED=$((COMMON_VARS_FAILED + TIER_VARS_FAILED))

echo "Total:"
echo "  ✅ Passed: $TOTAL_PASSED"
echo "  ❌ Failed: $TOTAL_FAILED"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "✨ All environment variables verified successfully!"
    exit 0
else
    echo "⚠️  Some environment variables failed verification"
    exit 1
fi
