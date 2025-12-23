# Traefik Container

**Tier**: 2 - Proxy  
**Component**: Reverse Proxy  
**Purpose**: Dynamic reverse proxy and load balancer for all foundation and project services

## Overview

This container provides Traefik as the central reverse proxy for the entire foundation layer, handling routing, load balancing, and TLS termination.

## Configuration

### Environment Variables

- `TRAEFIK_IMAGE`: Traefik image version (default: `traefik:v2.10`)
- `TRAEFIK_HTTP_PORT`: HTTP port (default: `80`)
- `TRAEFIK_HTTPS_PORT`: HTTPS port (default: `443`)
- `TRAEFIK_DASHBOARD_PORT`: Dashboard port (default: `3104`)
- `TRAEFIK_LOG_LEVEL`: Log level (default: `INFO`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `80`: HTTP entry point
- `443`: HTTPS entry point
- `3104`: Dashboard and API

### Volumes

- `./config/traefik.yml`: Static configuration (read-only)
- `./config/dynamic/`: Dynamic configuration (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/traefik/certs/`: TLS certificates (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/traefik/logs/`: Logs (read-write)
- `/var/run/docker.sock`: Docker socket for service discovery (read-only)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-traefik

# Access dashboard
open http://localhost:3104/dashboard/
```

## Service Discovery

Traefik automatically discovers services via Docker labels. Services must include:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(\`myservice.local\`)"
  - "traefik.http.services.myservice.loadbalancer.server.port=8080"
```

## Configuration Files

- `config/traefik.yml`: Static configuration (entry points, providers, logging)
- `config/dynamic/middlewares.yml`: Middleware definitions (auth, rate limiting, headers)
- `config/dynamic/routers.yml`: Static route definitions
- `config/dynamic/services.yml`: Static service definitions

## Middlewares

Available middlewares:
- `keycloak-forward-auth`: Keycloak authentication
- `rate-limit`: Rate limiting (100 avg, 50 burst)
- `security-headers`: Security headers
- `secure-rate-limit`: Combined security + rate limit
- `keycloak-secure`: Combined auth + security + rate limit

## Dependencies

- None (this is a foundational service)
- Requires Docker socket access for service discovery

## Dependents

- All services that need external access
- All services requiring reverse proxy

## Labels

- `tier=2`
- `component=proxy`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Dashboard: `http://traefik.local:3104/dashboard/`
- API: `http://traefik.local:3104/api/`
- Ping: `http://localhost/ping`

## Prometheus Integration

- Metrics endpoint: `/metrics`
- Port: `8080`

## Health Check

```bash
# Check health status
docker inspect foundation-traefik --format='{{.State.Health.Status}}'

# Test ping endpoint
curl http://localhost/ping
```

## Security Notes

- Dashboard is insecure in development (enable auth in production)
- HTTP to HTTPS redirect disabled for development
- Enable TLS in production
- Secure Docker socket access
- Use strong middleware chains for sensitive services
- Regular security updates via image updates
