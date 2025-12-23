# Changelog

All notable changes to the Foundation Layer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-23

### Added

#### Architecture & Structure
- Complete 6-tier microservices architecture
- Modular container-per-folder structure
- Self-contained configuration per container
- 13 Dockerfiles for future customization
- Comprehensive documentation per container (14 README files)

#### Tier 1 - Security Layer
- PostgreSQL 15 Alpine with custom initialization scripts
- HashiCorp Vault 1.21.1 with file storage backend
- Keycloak 26.4.7 with foundation realm pre-configured
- Health checks for all security services
- Vault policies for foundation services

#### Tier 2 - Proxy Layer
- Traefik v2.10 with Docker provider
- Dynamic service discovery
- Health check endpoints
- Metrics exposure for Prometheus
- Custom middleware configurations

#### Tier 3 - Registry Layer
- Docker Registry v2 with delete support
- Verdaccio latest for NPM packages
- Health checks for both registries
- Traefik routing integration

#### Tier 4 - Management Layer
- Portainer CE latest with Docker socket integration
- Web UI for container management
- Traefik authentication integration

#### Tier 5 - Observability Layer
- Prometheus latest with 15-day retention
- Grafana latest with pre-configured datasources
- Loki latest for log aggregation
- Promtail latest for log collection
- cAdvisor latest for container metrics
- Health checks where applicable

#### Tier 6 - AI-MCP Layer
- MCP Gateway latest with SSE transport
- Docker MCP server integration
- Health check endpoint

#### Configuration Management
- Common `.env` file for shared configuration
- Tier-specific `.env` files for overrides
- Environment variable validation
- No hardcoded values in docker-compose files
- `.foundation-config` for backward compatibility

#### Deployment & Automation
- `01-deploy-all-containers.sh` - Individual container deployment
- `02-stop-all-containers.sh` - Graceful shutdown
- `03-purge-all-containers.sh` - Resource cleanup (preserves images)
- `04-deploy-all-tiers.sh` - Tier-based deployment
- `05-verify-env-values.sh` - Comprehensive env validation
- `06-health-check-all.sh` - Detailed health checks
- `07-verify-env-quick.sh` - Quick env validation
- `08-health-check-quick.sh` - Quick health checks

#### Labels & Organization
- Service group naming with "foundation-" prefix
- Label-based filtering for all containers
- Portfolio, layer, project, and network labels
- Tier and component labels for categorization

#### Network & Storage
- Unified `foundation-layer-network` for all services
- External storage at `/docker-storage`
- Volume separation for data, logs, configs

### Changed

#### From v1.0 to v2.0
- **Structure**: Monolithic tier compose files → Modular container folders
- **Configuration**: Hardcoded values → Environment variables from .env files
- **Service Groups**: Generic names → "foundation-" prefixed names
- **Deployment**: Single script → Multiple specialized scripts
- **Verification**: Manual → Automated scripts
- **Customization**: Image-only → Dockerfile-based builds

### Fixed

- Service group naming consistency
- Environment variable loading from both common and tier-specific files
- Health check timeouts and reliability
- Network isolation and connectivity
- Label-based resource filtering
- Volume path configurations
- Traefik routing rules
- Keycloak database connectivity

### Security

- Removed hardcoded credentials from compose files
- Centralized secret management via Vault
- Environment variable-based configuration
- Network isolation between services
- Docker socket read-only access where possible

## [1.0.0] - 2025-12-20

### Added
- Initial 6-tier architecture
- Basic docker-compose configuration
- Manual deployment process
- Core services setup

## [Unreleased]

### Added
- Test framework with GitOps practices
- Unit tests for Tier 1, 2, and 5
- Integration tests for authentication and monitoring
- Test documentation and changelog
- Batch validation script
- Test issue tracking system

### Planned Features
- Kubernetes manifests
- Helm charts
- CI/CD pipeline integration
- Multi-environment configurations
- Automated backup procedures
- Service mesh integration
- Auto-scaling configurations
- Enhanced security hardening

---

## Version History

- **2.0.0** - Complete refactor with modular architecture and automation
- **1.0.0** - Initial release with basic 6-tier setup

## Migration Guide

### From v1.0 to v2.0

1. **Backup existing data**
   ```bash
   # Backup database
   docker exec foundation-postgres pg_dump -U keycloak keycloak > backup.sql
   
   # Backup Vault data
   cp -r /docker-storage/foundation/vault /backup/vault
   ```

2. **Stop old containers**
   ```bash
   cd codebase
   ./scripts/02-stop-all-containers.sh
   ```

3. **Deploy new version**
   ```bash
   cd codebase-new
   ./scripts/04-deploy-all-tiers.sh
   ```

4. **Verify migration**
   ```bash
   ./scripts/07-verify-env-quick.sh
   ./scripts/08-health-check-quick.sh
   ```

## Breaking Changes

### v2.0.0

- **Service Group Names**: All service groups now require "foundation-" prefix
- **Environment Variables**: All hardcoded values must be in `.env` files
- **File Structure**: Tier folders now contain sub-folders for each container
- **Build Process**: Dockerfiles now required for all containers
- **Configuration**: `.env` files now mandatory (no fallback defaults)

---

For detailed changes, see commit history and pull requests.
