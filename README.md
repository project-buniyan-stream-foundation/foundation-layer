# Foundation Layer - Project Bunyan Stream

**Version**: 2.0.0  
**Status**: Production Ready  
**Architecture**: 6-Tier Microservices Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-3.8+-blue.svg)](https://docs.docker.com/compose/)

## Overview

The Foundation Layer is a comprehensive, production-ready infrastructure stack designed to provide essential services for the Project Bunyan Stream ecosystem. It implements a 6-tier architecture with 13 containerized services, providing security, networking, storage, monitoring, and AI integration capabilities.

## Architecture

### 6-Tier Design

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Tier 6: AI-MCP Layer                            │
│                  MCP Gateway (AI Tool Integration)                      │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    Tier 5: Observability Layer                          │
│      Prometheus | Grafana | Loki | Promtail | cAdvisor                 │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     Tier 4: Management Layer                            │
│                         Portainer (UI)                                  │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      Tier 3: Registry Layer                             │
│              Docker Registry | Verdaccio (NPM)                          │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       Tier 2: Proxy Layer                               │
│                    Traefik (Reverse Proxy)                              │
└─────────────────────────────────────────────────────────────────────────┘
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      Tier 1: Security Layer                             │
│              PostgreSQL | Vault | Keycloak (SSO)                        │
└─────────────────────────────────────────────────────────────────────────┘
```

### Components (13 Services)

**Tier 1 - Security** (3 containers)
- **PostgreSQL**: Database for Keycloak authentication
- **HashiCorp Vault**: Centralized secrets management
- **Keycloak**: SSO/OAuth2 authentication provider

**Tier 2 - Proxy** (1 container)
- **Traefik**: Dynamic reverse proxy with service discovery

**Tier 3 - Registry** (2 containers)
- **Docker Registry**: Private container image registry
- **Verdaccio**: Private NPM package registry

**Tier 4 - Management** (1 container)
- **Portainer**: Web-based container management UI

**Tier 5 - Observability** (5 containers)
- **Prometheus**: Metrics collection and storage
- **Grafana**: Dashboards and visualization
- **Loki**: Log aggregation
- **Promtail**: Log collection agent
- **cAdvisor**: Container resource metrics

**Tier 6 - AI-MCP** (1 container)
- **MCP Gateway**: Model Context Protocol gateway for AI tool integration

## Features

### 🔐 Security First
- Centralized authentication via Keycloak
- Secrets management with HashiCorp Vault
- SSL/TLS ready with Traefik
- Network isolation
- Label-based resource management

### 📦 Modular Architecture
- Each container is self-contained with its own folder
- Dedicated configuration files per service
- Individual Dockerfiles for customization
- Tier-based organization for logical grouping

### ⚙️ Configuration Management
- Common `.env` file for shared configuration
- Tier-specific `.env` files for overrides
- Environment variable validation
- No hardcoded values

### 📊 Observability
- Full-stack monitoring with Prometheus
- Custom dashboards with Grafana
- Centralized logging with Loki
- Container metrics with cAdvisor
- Real-time log collection with Promtail

### 🚀 Production Ready
- Health checks for all services
- Automated deployment scripts
- Automated verification scripts
- Service dependency management
- Graceful shutdown procedures

## Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommended)
- 20GB disk space

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/project-buniyan-stream-foundation/foundation-layer.git
cd foundation-layer
```

2. **Configure environment variables**
```bash
# Copy and edit common configuration
cp .env.example .env

# Edit tier-specific configurations as needed
vi tier1-security/.env
vi tier2-proxy/.env
# ... etc
```

3. **Deploy all services**
```bash
./scripts/04-deploy-all-tiers.sh
```

4. **Verify deployment**
```bash
./scripts/07-verify-env-quick.sh
./scripts/08-health-check-quick.sh
```

### Accessing Services

**Security Services:**
- Keycloak: http://localhost:8180/admin
- Vault: http://localhost:8200/ui

**Proxy & Management:**
- Traefik Dashboard: http://localhost:3104/dashboard/
- Portainer: http://localhost:3103

**Registries:**
- Docker Registry: http://localhost:5000/v2/_catalog
- Verdaccio (NPM): http://localhost:4873

**Observability:**
- Prometheus: http://localhost:3101
- Grafana: http://localhost:3100
- cAdvisor: http://localhost:3102

**AI Integration:**
- MCP Gateway: http://localhost:8811/health

## Project Structure

```
foundation-layer/
├── .env                          # Common environment variables
├── .foundation-config            # Foundation configuration
├── README.md                     # This file
├── CHANGELOG.md                  # Version history
├── CONTRIBUTING.md               # Contribution guidelines
├── .gitignore                    # Git ignore rules
├── scripts/                      # Deployment and management scripts
│   ├── 01-deploy-all-containers.sh
│   ├── 02-stop-all-containers.sh
│   ├── 03-purge-all-containers.sh
│   ├── 04-deploy-all-tiers.sh
│   ├── 05-verify-env-values.sh
│   ├── 06-health-check-all.sh
│   ├── 07-verify-env-quick.sh
│   └── 08-health-check-quick.sh
├── tests/                        # Test suite
│   ├── 00-readme.md
│   ├── 01-changelog.md
│   ├── 02-test-plan.md
│   ├── 03-validation-results.md
│   ├── unit/                     # Unit tests per tier
│   ├── integration/              # Integration tests
│   ├── e2e/                      # End-to-end tests
│   ├── scripts/                  # Test execution scripts
│   └── issues/                   # Test issue tracking
├── tier1-security/               # Security layer
│   ├── .env
│   ├── docker-compose.yml
│   ├── postgres/
│   ├── vault/
│   └── keycloak/
├── tier2-proxy/                  # Proxy layer
│   ├── .env
│   ├── docker-compose.yml
│   └── traefik/
├── tier3-registry/               # Registry layer
│   ├── .env
│   ├── docker-compose.yml
│   ├── docker-registry/
│   └── verdaccio/
├── tier4-management/             # Management layer
│   ├── .env
│   ├── docker-compose.yml
│   └── portainer/
├── tier5-observability/          # Observability layer
│   ├── .env
│   ├── docker-compose.yml
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   ├── promtail/
│   └── cadvisor/
└── tier6-ai-mcp/                 # AI-MCP layer
    ├── .env
    ├── docker-compose.yml
    └── mcp-gateway/
```

## Deployment

### Deploy All Tiers

```bash
# Automated deployment of all 6 tiers
./scripts/04-deploy-all-tiers.sh
```

### Deploy Individual Tier

```bash
# Example: Deploy only Tier 1 (Security)
cd tier1-security
docker compose up -d
```

### Deploy Individual Container

```bash
# Example: Deploy only PostgreSQL
cd tier1-security
docker compose up -d foundation-postgres
```

## Management

### Stop All Containers

```bash
./scripts/02-stop-all-containers.sh
```

### Purge All Resources (Keep Images)

```bash
# Interactive (with confirmation)
./scripts/03-purge-all-containers.sh

# Force (no confirmation)
FORCE_PURGE=true ./scripts/03-purge-all-containers.sh
```

## Verification

### Environment Variables

```bash
./scripts/07-verify-env-quick.sh
```

### Health Check

```bash
./scripts/08-health-check-quick.sh
```

### Run Test Suite

```bash
# Run all tests
./tests/scripts/run-all-tests.sh

# Run batch validation
./tests/scripts/run-batch-validation.sh

# Run tier-specific tests
./tests/unit/tier1-security/test-tier1-security.sh
./tests/unit/tier2-proxy/test-tier2-proxy.sh
./tests/unit/tier5-observability/test-tier5-observability.sh
```

### Manual Checks

```bash
# Check service groups
docker ps --filter "label=portfolio=portfolio-bunyan" \
  --format "{{.Label \"com.docker.compose.project\"}}\t{{.Names}}"

# Check network
docker network inspect foundation-layer-network

# Check container health
docker ps --filter "label=portfolio=portfolio-bunyan" \
  --format "{{.Names}}: {{.Status}}"
```

## Configuration

### Common Configuration (.env)

Shared across all tiers:
```bash
DOCKER_STORAGE_ROOT=/docker-storage
PORTFOLIO_NAME=portfolio-bunyan
LAYER_NAME=foundation-layer
PROJECT_NAME=stream-foundation
NETWORK_NAME=foundation-layer-network
```

### Tier-Specific Configuration

Each tier has its own `.env` file with service-specific variables:
- `tier1-security/.env` - PostgreSQL, Vault, Keycloak
- `tier2-proxy/.env` - Traefik
- `tier3-registry/.env` - Docker Registry, Verdaccio
- `tier4-management/.env` - Portainer
- `tier5-observability/.env` - Prometheus, Grafana, Loki, Promtail, cAdvisor
- `tier6-ai-mcp/.env` - MCP Gateway

**Override Mechanism**: Common `.env` is loaded first, tier-specific `.env` overrides common values.

## Branching Strategy

### Main Branches

- `main` - Production-ready code, stable releases
- `develop` - Integration branch for all features

### Feature Branches

- `feature/tier1-security` - Security layer development
- `feature/tier2-proxy` - Proxy layer development
- `feature/tier3-registry` - Registry layer development
- `feature/tier4-management` - Management layer development
- `feature/tier5-observability` - Observability layer development
- `feature/tier6-ai-mcp` - AI-MCP layer development

### Workflow

1. Create feature branch from `develop`
2. Develop and test in feature branch
3. Create pull request to `develop`
4. After testing, merge `develop` to `main`
5. Tag release on `main`

## Labels and Tags

All containers are tagged with:
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`
- `tier=<1-6>`
- `component=<type>`

## Network

All services communicate via: `foundation-layer-network`

## Storage

Default storage location: `/docker-storage`

Structure:
```
/docker-storage/foundation/
├── postgres/data/
├── vault/data/
├── vault/logs/
├── keycloak/data/
├── keycloak/themes/
├── traefik/certs/
├── traefik/logs/
├── docker-registry/data/
├── verdaccio/storage/
├── portainer/data/
├── prometheus/data/
├── grafana/data/
├── loki/data/
└── mcp-gateway/data/
```

## Security Considerations

### Secrets Management

- **NEVER** commit `.env` files to git
- Use `.env.example` as template
- Change all default passwords in production
- Rotate secrets regularly
- Use Vault for sensitive data

### Default Credentials

**⚠️ CHANGE THESE IN PRODUCTION:**

- Keycloak Admin: `admin` / `change-me-in-production`
- Grafana Admin: `admin` / `change-me-in-production`
- PostgreSQL: `keycloak` / `change-me-in-production`
- Portainer: Set on first login

## Monitoring

### Prometheus Metrics

All services expose Prometheus metrics. Access Prometheus at http://localhost:3101

### Grafana Dashboards

Pre-configured dashboards available at http://localhost:3100

### Logs

Centralized logging via Loki. Query logs through Grafana.

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs <container-name>

# Check network
docker network inspect foundation-layer-network

# Check environment variables
docker exec <container-name> printenv
```

### Health Check Fails

```bash
# Run automated health check
./scripts/08-health-check-quick.sh

# Check individual service
docker inspect <container-name> --format='{{.State.Health.Status}}'
```

### Environment Variables Not Loading

```bash
# Verify .env files exist
ls -la .env tier*/.env

# Run automated verification
./scripts/07-verify-env-quick.sh
```

## Development

### Building Custom Images

Each container has a Dockerfile for customization:

```bash
# Build custom image
cd tier1-security/postgres
docker build -t custom-postgres .

# Update .env to use custom image
# POSTGRES_IMAGE=custom-postgres
```

### Adding New Services

1. Create container folder in appropriate tier
2. Add Dockerfile
3. Add configuration files
4. Update tier's docker-compose.yml
5. Update tier's .env file
6. Test deployment
7. Update documentation

## Contributing

### Branch Naming

- `feature/<tier-name>` - Feature development
- `bugfix/<description>` - Bug fixes
- `hotfix/<description>` - Urgent production fixes

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(tier1): add postgresql initialization script
fix(tier2): correct traefik routing configuration
docs(readme): update deployment instructions
chore(deps): update vault to 1.21.1
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- GitHub Issues: https://github.com/project-buniyan-stream-foundation/foundation-layer/issues
- Documentation: See individual tier README files

## Acknowledgments

Built with:
- PostgreSQL
- HashiCorp Vault
- Keycloak
- Traefik
- Docker Registry
- Verdaccio
- Portainer
- Prometheus
- Grafana
- Loki
- Promtail
- cAdvisor
- Docker MCP Gateway

## Roadmap

- [x] Core 6-tier architecture
- [x] Complete observability stack
- [x] Automated deployment scripts
- [x] Environment variable management
- [x] Health check automation
- [x] Dockerfile-based customization
- [ ] Kubernetes manifests
- [ ] Helm charts
- [ ] CI/CD pipelines
- [ ] Multi-environment support
- [ ] Auto-scaling configurations

---

**Project Bunyan Stream Foundation Layer** - Enterprise-grade infrastructure stack
