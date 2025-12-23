# Grafana Container

**Tier**: 5 - Observability  
**Component**: Dashboards and Visualization  
**Purpose**: Visualization and dashboards for metrics and logs

## Overview

This container provides Grafana for creating dashboards and visualizing data from Prometheus and Loki.

## Configuration

### Environment Variables

- `GRAFANA_IMAGE`: Grafana image version (default: `grafana/grafana:latest`)
- `GRAFANA_PORT`: Grafana port (default: `3100`)
- `GRAFANA_ADMIN_USER`: Admin username (default: `admin`)
- `GRAFANA_ADMIN_PASSWORD`: Admin password (default: `change-me-in-production`)
- `GRAFANA_OAUTH_ENABLED`: Enable OAuth (default: `true`)
- `GRAFANA_OAUTH_CLIENT_ID`: OAuth client ID (default: `grafana`)
- `GRAFANA_OAUTH_CLIENT_SECRET`: OAuth client secret (default: `change-me`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `3100`: Grafana web UI (mapped from internal 3000)

### Volumes

- `./config/datasources/`: Provisioned datasources (read-only)
- `./config/dashboards/`: Provisioned dashboards (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/grafana/data/`: Grafana data (read-write)

## Deployment

```bash
# Deploy standalone (requires prometheus and loki)
docker compose up -d

# View logs
docker logs foundation-grafana

# Access web UI
open http://localhost:3100
```

## Initial Setup

1. Access Grafana at `http://localhost:3100`
2. Login with admin credentials
3. Datasources are auto-provisioned:
   - Prometheus (metrics)
   - Loki (logs)
4. Create or import dashboards

## Dependencies

- `foundation-prometheus`: Metrics data source (required)
- `foundation-loki`: Logs data source (required)
- `foundation-keycloak`: OAuth authentication (optional)

## Dependents

- None (this is a visualization service)

## Health Check

```bash
# Check health status
docker inspect foundation-grafana --format='{{.State.Health.Status}}'

# Check Grafana health endpoint
curl http://localhost:3100/api/health
```

## Labels

- `tier=5`
- `component=observability`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://grafana.local`
- Requires Keycloak authentication
- Service: `grafana`
- Port: `3000` (internal)

## Prometheus Integration

- Metrics endpoint: `/metrics`
- Port: `3000`

## Keycloak Integration

Grafana can authenticate via Keycloak OAuth2:
- Realm: `foundation`
- Client: `grafana`
- Auth URL: `http://foundation-keycloak:8080/auth/realms/foundation/protocol/openid-connect/auth`

## Pre-configured Datasources

1. **Prometheus**
   - URL: `http://foundation-prometheus:9090`
   - Type: Prometheus
   - Access: Proxy

2. **Loki**
   - URL: `http://foundation-loki:3100`
   - Type: Loki
   - Access: Proxy

## Dashboard Examples

Common dashboards to create:
- Container metrics (CPU, memory, network)
- Application logs
- Service health
- Alert status
- Resource utilization

## Security Notes

- Change default admin password immediately
- Enable OAuth in production
- Use strong passwords
- Enable HTTPS in production
- Restrict network access
- Regular security updates via image updates
