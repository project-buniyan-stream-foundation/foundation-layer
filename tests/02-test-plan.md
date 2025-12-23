# Foundation Layer - Test Plan

**Version**: 1.0.0  
**Status**: Active  
**Last Updated**: 2025-12-23

---

## Test Strategy

### Objectives
1. Validate all foundation services are correctly configured
2. Verify inter-tier integration and dependencies
3. Ensure authentication and authorization flows work correctly
4. Validate monitoring and observability capabilities
5. Confirm data persistence and recovery

### Approach
- **Test-Driven**: Tests developed alongside features
- **Automated**: All tests executable via scripts
- **Repeatable**: Tests can run multiple times with consistent results
- **Isolated**: Tests don't interfere with each other
- **Documented**: Clear test descriptions and expected outcomes

---

## Test Levels

### Level 1: Unit Tests
**Purpose**: Validate individual service configuration and basic functionality

**Scope**:
- Container startup and health checks
- Environment variable loading
- Volume mounts and persistence
- Network connectivity
- Service-specific functionality

**Execution**: Per-tier test scripts

### Level 2: Integration Tests
**Purpose**: Validate interactions between tiers

**Scope**:
- Cross-tier communication
- Authentication flows
- Service discovery
- Metrics collection
- Log aggregation

**Execution**: Cross-tier test scripts

### Level 3: End-to-End Tests
**Purpose**: Validate complete workflows

**Scope**:
- Full deployment process
- Complete authentication workflow
- Monitoring and alerting workflow
- Backup and recovery procedures

**Execution**: E2E test scripts

---

## Test Coverage

### Tier 1: Security Layer

#### Unit Tests
- [ ] PostgreSQL container health
- [ ] PostgreSQL database initialization
- [ ] PostgreSQL environment variables
- [ ] PostgreSQL data persistence
- [ ] Vault container health
- [ ] Vault initialization and unsealing
- [ ] Vault policy configuration
- [ ] Vault metrics endpoint
- [ ] Keycloak container health
- [ ] Keycloak database connection
- [ ] Keycloak realm import
- [ ] Keycloak OAuth2 clients configuration
- [ ] Keycloak admin console access

#### Integration Tests
- [ ] Keycloak → PostgreSQL connection
- [ ] Keycloak → Traefik routing
- [ ] Vault → Traefik routing
- [ ] Keycloak → Prometheus metrics
- [ ] Vault → Prometheus metrics

### Tier 2: Proxy Layer

#### Unit Tests
- [ ] Traefik container health
- [ ] Traefik configuration loading
- [ ] Traefik entry points
- [ ] Traefik Docker provider
- [ ] Traefik file provider
- [ ] Traefik dashboard access
- [ ] Traefik ping endpoint
- [ ] Traefik metrics endpoint

#### Integration Tests
- [ ] Traefik → Keycloak forward auth
- [ ] Traefik → All services routing
- [ ] Traefik → Service discovery
- [ ] Traefik → Prometheus metrics

### Tier 3: Registry Layer

#### Unit Tests
- [ ] Docker Registry container health
- [ ] Docker Registry API endpoints
- [ ] Docker Registry storage configuration
- [ ] Verdaccio container health
- [ ] Verdaccio web UI access
- [ ] Verdaccio storage configuration

#### Integration Tests
- [ ] Docker Registry → Traefik routing
- [ ] Verdaccio → Traefik routing
- [ ] Registries → Keycloak authentication
- [ ] Registries → Prometheus metrics

### Tier 4: Management Layer

#### Unit Tests
- [ ] Portainer container health
- [ ] Portainer Docker socket access
- [ ] Portainer data persistence
- [ ] Portainer API access

#### Integration Tests
- [ ] Portainer → Traefik routing
- [ ] Portainer → Keycloak authentication
- [ ] Portainer → Docker API functionality

### Tier 5: Observability Layer

#### Unit Tests
- [ ] Prometheus container health
- [ ] Prometheus configuration loading
- [ ] Prometheus scraping targets
- [ ] Prometheus data retention
- [ ] Grafana container health
- [ ] Grafana datasources configuration
- [ ] Grafana dashboard provisioning
- [ ] Loki container health
- [ ] Loki API endpoints
- [ ] Promtail container health
- [ ] Promtail log collection
- [ ] cAdvisor container health
- [ ] cAdvisor metrics collection

#### Integration Tests
- [ ] Prometheus → All services scraping
- [ ] Grafana → Prometheus datasource
- [ ] Grafana → Loki datasource
- [ ] Grafana → Keycloak OAuth2
- [ ] Promtail → Loki log shipping
- [ ] cAdvisor → Prometheus metrics

### Tier 6: AI-MCP Layer

#### Unit Tests
- [ ] MCP Gateway container health
- [ ] MCP Gateway configuration loading
- [ ] MCP Gateway Docker socket access
- [ ] MCP Gateway health endpoint
- [ ] MCP Gateway SSE endpoint

#### Integration Tests
- [ ] MCP Gateway → Traefik routing
- [ ] MCP Gateway → Keycloak authentication
- [ ] MCP Gateway → Prometheus metrics
- [ ] MCP Gateway → Docker MCP integration

---

## End-to-End Test Scenarios

### E2E-001: Full Deployment
**Objective**: Validate complete deployment process

**Steps**:
1. Purge all existing containers
2. Create foundation network
3. Deploy Tier 1 (Security)
4. Verify Tier 1 health
5. Deploy Tier 2 (Proxy)
6. Verify Tier 2 health
7. Deploy Tiers 3-6
8. Verify all services healthy
9. Verify service groups
10. Verify network connectivity

**Expected Outcome**: All 13 containers running and healthy

### E2E-002: Authentication Flow
**Objective**: Validate complete authentication workflow

**Steps**:
1. Access Grafana via Traefik
2. Redirect to Keycloak login
3. Authenticate with Keycloak
4. Receive OAuth2 token
5. Access Grafana dashboard
6. Verify user session

**Expected Outcome**: Successful authentication and dashboard access

### E2E-003: Monitoring Workflow
**Objective**: Validate monitoring and alerting

**Steps**:
1. Verify Prometheus scraping all targets
2. Verify metrics available in Prometheus
3. Access Grafana dashboards
4. Verify metrics visualization
5. Query logs in Grafana via Loki
6. Verify log aggregation working

**Expected Outcome**: Complete observability stack functional

### E2E-004: Service Discovery
**Objective**: Validate automatic service discovery

**Steps**:
1. Deploy new service with Traefik labels
2. Verify Traefik discovers service
3. Verify routing configured automatically
4. Verify Prometheus discovers service
5. Verify metrics scraped automatically

**Expected Outcome**: Automatic discovery and configuration

---

## Test Execution

### Prerequisites
- Docker Engine running
- Docker Compose available
- Foundation containers deployed
- Network `foundation-layer-network` exists

### Execution Order
1. Unit tests (per tier, in deployment order)
2. Integration tests (cross-tier dependencies)
3. End-to-end tests (complete workflows)

### Test Environment
- **Development**: Local Docker environment
- **CI/CD**: Automated test environment
- **Staging**: Pre-production validation

---

## Test Metrics

### Coverage Goals
- **Unit Tests**: 100% of services
- **Integration Tests**: 100% of tier interactions
- **E2E Tests**: All critical workflows

### Success Criteria
- All unit tests pass
- All integration tests pass
- All E2E tests pass
- No critical issues found
- Performance within acceptable limits

---

## Test Reporting

### Report Format
- Test execution summary
- Pass/fail counts per category
- Failed test details
- Execution time
- Environment information

### Report Location
- `tests/reports/` (gitignored)
- CI/CD artifacts
- Test result dashboard (future)

---

## Maintenance

### Test Updates
- Update tests when features change
- Add tests for new features
- Remove tests for deprecated features
- Refactor tests for maintainability

### Issue Tracking
- Create issues for test failures
- Track test development in `tests/issues/`
- Link tests to feature issues

---

## Future Enhancements

### Planned
- Performance benchmarking tests
- Security scanning tests
- Chaos engineering tests
- Load testing
- Automated test reporting
- CI/CD integration
- Test result visualization

### Under Consideration
- Contract testing
- Mutation testing
- Property-based testing
- Fuzz testing
