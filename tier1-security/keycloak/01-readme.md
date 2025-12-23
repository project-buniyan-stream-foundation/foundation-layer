# Keycloak Container

**Tier**: 1 - Security  
**Component**: SSO/OAuth2 Provider  
**Purpose**: Centralized authentication and authorization for all foundation and project services

## Overview

This container provides Keycloak SSO/OAuth2 authentication for the entire foundation layer and all projects.

## Configuration

### Environment Variables

- `KEYCLOAK_ADMIN`: Admin username (default: `admin`)
- `KEYCLOAK_ADMIN_PASSWORD`: Admin password (default: `change-me-in-production`)
- `KC_DB`: Database type (default: `postgres`)
- `KC_DB_URL`: Database JDBC URL
- `KC_DB_USERNAME`: Database username (default: `keycloak`)
- `KC_DB_PASSWORD`: Database password (default: `change-me-in-production`)
- `KC_HOSTNAME`: Keycloak hostname (default: `localhost`)
- `KC_HOSTNAME_PORT`: Keycloak port (default: `8180`)
- `KEYCLOAK_HTTP_PORT`: External HTTP port (default: `8180`)
- `KEYCLOAK_HTTPS_PORT`: External HTTPS port (default: `8443`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `8180`: Keycloak HTTP port (mapped from internal 8080)
- `8443`: Keycloak HTTPS port

### Volumes

- `./config/realms/`: Realm configurations (read-only, imported on startup)
- `${DOCKER_STORAGE_ROOT}/foundation/keycloak/data/`: Keycloak data (read-write)
- `${DOCKER_STORAGE_ROOT}/foundation/keycloak/themes/`: Custom themes (read-write)

## Deployment

```bash
# Deploy standalone (requires postgres)
docker compose up -d

# View logs
docker logs foundation-keycloak

# Access admin console
open http://localhost:8180/admin/master/console/
```

## Dependencies

- `foundation-postgres`: Database backend (required)

## Dependents

- All foundation services requiring authentication
- All project services requiring authentication

## Initial Setup

1. Wait for Keycloak to fully start (may take 60+ seconds)
2. Access admin console: `http://localhost:8180/admin/master/console/`
3. Login with admin credentials
4. Foundation realm is auto-imported from `config/realms/foundation-realm.json`

## Realm Configuration

The foundation realm includes pre-configured clients for:
- Traefik (reverse proxy)
- Grafana (monitoring dashboards)
- Portainer (container management)
- MCP Gateway (AI tools)

## Labels

- `tier=1`
- `component=security`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://keycloak.local` or `/auth` path
- Service: `keycloak`
- Port: `8080` (internal)

## Prometheus Integration

- Metrics endpoint: `/metrics`
- Port: `8080`

## Security Notes

- Change default admin password immediately
- Enable HTTPS in production
- Configure proper hostname and ports
- Use strong client secrets
- Enable 2FA for admin accounts
- Regular security updates via image updates
- Review and audit realm configurations
