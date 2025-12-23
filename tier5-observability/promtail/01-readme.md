# Promtail Container

**Tier**: 5 - Observability  
**Component**: Log Collector  
**Purpose**: Collect and ship container logs to Loki

## Overview

This container provides Grafana Promtail for collecting logs from Docker containers and shipping them to Loki.

## Configuration

### Environment Variables

- `PROMTAIL_IMAGE`: Promtail image version (default: `grafana/promtail:latest`)

### Ports

- None (Promtail doesn't expose ports, it pushes logs to Loki)

### Volumes

- `/var/run/docker.sock`: Docker socket for container discovery (read-only)
- `./config/promtail-config.yaml`: Promtail configuration (read-only)
- `/var/lib/docker/containers`: Container logs (read-only)
- `/var/log`: System logs (read-only)

## Deployment

```bash
# Deploy standalone (requires loki)
docker compose up -d

# View logs
docker logs foundation-promtail
```

## Configuration

### Log Collection

Promtail collects logs from:
- Docker container stdout/stderr
- Docker container log files
- System log files (optional)

### Log Processing

- Adds labels (container name, image, etc.)
- Parses log formats
- Filters logs
- Ships to Loki

## Dependencies

- `foundation-loki`: Log aggregation backend (required)
- Docker socket access (required)

## Dependents

- None (this is a log shipper)

## Health Check

Promtail doesn't have a built-in health check. Verify via:

```bash
# Check if container is running
docker ps --filter "name=foundation-promtail"

# Check logs for errors
docker logs foundation-promtail --tail 50
```

## Labels

- `tier=5`
- `component=observability`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Log Labels

Promtail adds these labels to collected logs:
- `container_name`: Container name
- `container_id`: Container ID
- `image_name`: Container image
- `stream`: stdout or stderr
- `filename`: Log file path

## Configuration File

`promtail-config.yaml` defines:
- Loki endpoint
- Scrape configs
- Label extraction
- Log parsing rules

## Integration with Loki

Promtail pushes logs to Loki at:
- URL: `http://foundation-loki:3100/loki/api/v1/push`
- Protocol: HTTP
- Format: Protobuf or JSON

## Troubleshooting

```bash
# Check if Promtail is collecting logs
docker logs foundation-promtail | grep "clients/client.go"

# Check if Promtail can reach Loki
docker exec foundation-promtail wget -O- http://foundation-loki:3100/ready

# View Promtail metrics (if exposed)
curl http://localhost:9080/metrics
```

## Security Notes

- Requires Docker socket access (read-only)
- No authentication to Loki by default
- Restrict network access
- Regular security updates via image updates
