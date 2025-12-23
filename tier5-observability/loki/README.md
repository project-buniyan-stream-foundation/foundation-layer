# Loki Container

**Tier**: 5 - Observability  
**Component**: Log Aggregation  
**Purpose**: Centralized log aggregation and storage for all foundation services

## Overview

This container provides Grafana Loki for aggregating and storing logs from all foundation and project services.

## Configuration

### Environment Variables

- `LOKI_IMAGE`: Loki image version (default: `grafana/loki:latest`)
- `LOKI_PORT`: Loki port (default: `3200`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `3200`: Loki HTTP API (mapped from internal 3100)

### Volumes

- `./config/loki-config.yaml`: Loki configuration (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/loki/data/`: Log data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-loki

# Query logs via API
curl http://localhost:3200/loki/api/v1/labels
```

## Configuration

### Log Ingestion

Loki receives logs from:
- `foundation-promtail`: Collects Docker container logs
- Applications with Loki logging drivers
- Direct HTTP API calls

### Data Retention

Configured in `loki-config.yaml`:
- Retention period
- Chunk size
- Index period

## Dependencies

- None (this is a foundational observability service)

## Dependents

- `foundation-promtail`: Sends logs to Loki
- `foundation-grafana`: Queries logs from Loki

## Health Check

Loki is a minimal Go binary without built-in health check. Verify via:

```bash
# Check if container is running
docker ps --filter "name=foundation-loki"

# Query labels endpoint
curl http://localhost:3200/loki/api/v1/labels

# Check metrics
curl http://localhost:3200/metrics
```

## Labels

- `tier=5`
- `component=observability`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Prometheus Integration

- Metrics endpoint: `/metrics`
- Port: `3100` (internal)

## API Endpoints

- `/loki/api/v1/push`: Push logs
- `/loki/api/v1/query`: Query logs
- `/loki/api/v1/query_range`: Query logs with time range
- `/loki/api/v1/labels`: Get label names
- `/loki/api/v1/label/<name>/values`: Get label values

## Query Examples

```logql
# All logs from a container
{container_name="foundation-postgres"}

# Logs with specific level
{container_name="foundation-keycloak"} |= "ERROR"

# Logs in time range
{container_name="foundation-traefik"} [5m]
```

## Integration with Grafana

Loki is pre-configured as a datasource in Grafana:
- URL: `http://foundation-loki:3100`
- Access: Proxy
- Type: Loki

## Security Notes

- No authentication by default (add in production)
- Restrict network access to trusted services
- Monitor disk usage (logs can grow large)
- Regular security updates via image updates
