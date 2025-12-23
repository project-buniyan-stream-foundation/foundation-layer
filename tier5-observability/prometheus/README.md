# Prometheus Container

**Tier**: 5 - Observability  
**Component**: Metrics Collection  
**Purpose**: Time-series metrics collection and monitoring for all foundation services

## Overview

This container provides Prometheus for collecting, storing, and querying metrics from all foundation and project services.

## Configuration

### Environment Variables

- `PROMETHEUS_IMAGE`: Prometheus image version (default: `prom/prometheus:latest`)
- `PROMETHEUS_PORT`: Prometheus port (default: `3101`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `3101`: Prometheus web UI and API (mapped from internal 9090)

### Volumes

- `/var/run/docker.sock`: Docker socket for service discovery (read-only)
- `./config/prometheus.yml`: Prometheus configuration (read-only)
- `./config/rules/`: Alert rules (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/prometheus/data/`: Time-series data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-prometheus

# Access web UI
open http://localhost:3101
```

## Configuration

### Scrape Targets

Prometheus automatically discovers services via Docker labels:
- Services with `prometheus.io/scrape=true` label
- Custom port via `prometheus.io/port` label
- Custom path via `prometheus.io/path` label

### Data Retention

- Default: 15 days
- Configurable via `--storage.tsdb.retention.time` flag

## Dependencies

- None (this is a foundational observability service)

## Dependents

- `foundation-grafana`: Uses Prometheus as a data source
- All services with Prometheus metrics endpoints

## Health Check

```bash
# Check health status
docker inspect foundation-prometheus --format='{{.State.Health.Status}}'

# Check Prometheus health endpoint
curl http://localhost:3101/-/healthy
```

## Labels

- `tier=5`
- `component=observability`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://prometheus.local`
- Requires Keycloak authentication
- Service: `prometheus`
- Port: `9090` (internal)

## Prometheus Integration

- Metrics endpoint: `/metrics`
- Port: `9090`
- Self-monitoring enabled

## Query Examples

```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Container memory usage
container_memory_usage_bytes

# HTTP request rate
rate(http_requests_total[5m])

# Service uptime
up{job="foundation-services"}
```

## Alert Rules

Alert rules are defined in `config/rules/foundation-alerts.yml`:
- High CPU usage
- High memory usage
- Service down
- Disk space low

## Security Notes

- Web UI accessible without authentication in development
- Enable authentication in production
- Restrict network access to trusted services
- Regular security updates via image updates
