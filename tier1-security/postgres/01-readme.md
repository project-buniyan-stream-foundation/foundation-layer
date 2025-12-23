# PostgreSQL Container

**Tier**: 1 - Security  
**Component**: Database  
**Purpose**: PostgreSQL database for Keycloak authentication

## Overview

This container provides the PostgreSQL database backend for Keycloak SSO/OAuth2 provider.

## Configuration

### Environment Variables

- `POSTGRES_DB`: Database name (default: `keycloak`)
- `POSTGRES_USER`: Database user (default: `keycloak`)
- `POSTGRES_PASSWORD`: Database password (default: `change-me-in-production`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `5432`: PostgreSQL database port

### Volumes

- `./config/init/`: Initialization scripts (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/postgres/data/`: Database data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# Deploy with custom storage root
DOCKER_STORAGE_ROOT=/custom/path docker compose up -d

# View logs
docker logs foundation-postgres

# Access database
docker exec -it foundation-postgres psql -U keycloak -d keycloak
```

## Health Check

The container includes a health check that verifies PostgreSQL is ready:

```bash
# Check health status
docker inspect foundation-postgres --format='{{.State.Health.Status}}'
```

## Dependencies

- None (this is a foundational service)

## Dependents

- `foundation-keycloak`: Uses this database for authentication data

## Labels

- `tier=1`
- `component=database`
- `backup=true`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Backup

This container is marked for backup (`backup=true`). Ensure regular backups of the database data volume.

## Security Notes

- Change default password in production
- Restrict network access to only required services
- Enable SSL/TLS in production environments
- Regular security updates via image updates
