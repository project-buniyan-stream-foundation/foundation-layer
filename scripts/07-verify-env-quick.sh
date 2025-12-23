#!/bin/bash
# verify-env-quick.sh
# Quick verification of environment variables in containers
# Project Bunyan - Foundation Stream

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEBASE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Quick Environment Variables Verification"
echo "============================================="
echo ""

# Load common .env
if [ -f "$CODEBASE_ROOT/.env" ]; then
    source "$CODEBASE_ROOT/.env"
fi

PASSED=0
FAILED=0

# Check common variable in a few containers
echo "Checking DOCKER_STORAGE_ROOT (common variable):"
for container in foundation-postgres foundation-grafana foundation-vault; do
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        value=$(docker exec "$container" printenv DOCKER_STORAGE_ROOT 2>/dev/null || echo "NOT_SET")
        if [ "$value" = "$DOCKER_STORAGE_ROOT" ]; then
            echo "  ✅ $container: $value"
            ((PASSED++))
        else
            echo "  ❌ $container: $value (expected: $DOCKER_STORAGE_ROOT)"
            ((FAILED++))
        fi
    fi
done
echo ""

# Check tier-specific variables
echo "Checking tier-specific variables:"
if docker ps --format "{{.Names}}" | grep -q "^foundation-postgres$"; then
    db=$(docker exec foundation-postgres printenv POSTGRES_DB 2>/dev/null || echo "NOT_SET")
    if [ "$db" = "keycloak" ]; then
        echo "  ✅ foundation-postgres POSTGRES_DB: $db"
        ((PASSED++))
    else
        echo "  ❌ foundation-postgres POSTGRES_DB: $db (expected: keycloak)"
        ((FAILED++))
    fi
fi

if docker ps --format "{{.Names}}" | grep -q "^foundation-grafana$"; then
    user=$(docker exec foundation-grafana printenv GF_SECURITY_ADMIN_USER 2>/dev/null || echo "NOT_SET")
    if [ "$user" = "admin" ]; then
        echo "  ✅ foundation-grafana GF_SECURITY_ADMIN_USER: $user"
        ((PASSED++))
    else
        echo "  ❌ foundation-grafana GF_SECURITY_ADMIN_USER: $user (expected: admin)"
        ((FAILED++))
    fi
fi
echo ""

echo "Summary: ✅ Passed: $PASSED, ❌ Failed: $FAILED"
if [ $FAILED -eq 0 ]; then
    echo "✨ All environment variables verified!"
    exit 0
else
    echo "⚠️  Some environment variables failed verification"
    exit 1
fi
