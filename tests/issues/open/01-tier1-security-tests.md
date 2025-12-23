# Test Issue #1: Tier 1 Security - Unit Tests

**Status**: Open  
**Priority**: Critical  
**Category**: Unit Tests  
**Tier**: 1 - Security  
**Created**: 2025-12-23

---

## Objective

Implement comprehensive unit tests for Tier 1 Security layer (PostgreSQL, Vault, Keycloak).

---

## Test Requirements

### PostgreSQL Tests
- [ ] Test container is running
- [ ] Test container is healthy
- [ ] Test environment variables loaded correctly
- [ ] Test database initialized (keycloak database exists)
- [ ] Test data volume mounted correctly
- [ ] Test init scripts executed
- [ ] Test PostgreSQL accessible on configured port
- [ ] Test connection from Keycloak works
- [ ] Test Prometheus labels configured
- [ ] Test health check endpoint responds

### Vault Tests
- [ ] Test container is running
- [ ] Test container is healthy
- [ ] Test environment variables loaded correctly
- [ ] Test Vault configuration file loaded
- [ ] Test data volume mounted correctly
- [ ] Test logs volume mounted correctly
- [ ] Test Vault API accessible
- [ ] Test Vault policies loaded
- [ ] Test metrics endpoint accessible
- [ ] Test Traefik labels configured

### Keycloak Tests
- [ ] Test container is running
- [ ] Test container health (may not have health check)
- [ ] Test environment variables loaded correctly
- [ ] Test database connection configured
- [ ] Test realm import directory mounted
- [ ] Test data volume mounted correctly
- [ ] Test themes volume mounted correctly
- [ ] Test foundation realm imported
- [ ] Test OAuth2 clients configured (traefik, grafana, portainer, mcp-gateway)
- [ ] Test admin console accessible
- [ ] Test metrics endpoint accessible
- [ ] Test Traefik labels configured
- [ ] Test depends_on PostgreSQL configured

---

## Test Implementation

### Script Location
`tests/unit/tier1-security/test-tier1-security.sh`

### Test Structure
```bash
#!/bin/bash
# Unit Tests: Tier 1 Security Layer
# Tests: PostgreSQL, Vault, Keycloak

set -e

PASSED=0
FAILED=0

# PostgreSQL Tests
test_postgres_running() { ... }
test_postgres_healthy() { ... }
test_postgres_env_vars() { ... }
test_postgres_database() { ... }

# Vault Tests
test_vault_running() { ... }
test_vault_healthy() { ... }
test_vault_api() { ... }

# Keycloak Tests
test_keycloak_running() { ... }
test_keycloak_realm() { ... }
test_keycloak_clients() { ... }

# Execute all tests
run_all_tests() {
    test_postgres_running
    test_postgres_healthy
    # ... all tests
}

run_all_tests
echo "Summary: ✅ $PASSED passed, ❌ $FAILED failed"
exit $FAILED
```

---

## Acceptance Criteria

- All PostgreSQL tests pass
- All Vault tests pass
- All Keycloak tests pass
- Test script executable and documented
- Test results clearly reported
- Failed tests provide diagnostic information

---

## Dependencies

- Tier 1 containers must be running
- Docker CLI access
- curl or wget for HTTP tests
- jq for JSON parsing (optional)

---

## Notes

- Tests assume containers are already deployed
- Tests should not modify container state
- Tests should be idempotent (repeatable)
- Tests should complete within reasonable time (< 2 minutes)
