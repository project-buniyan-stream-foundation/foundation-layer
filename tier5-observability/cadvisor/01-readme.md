# cAdvisor Container

**Tier**: 5 - Observability  
**Component**: Container Metrics  
**Purpose**: Collect detailed container resource usage metrics

## Overview

This container provides Google cAdvisor for collecting detailed resource usage and performance metrics from running containers.

## Configuration

### Environment Variables

- `CADVISOR_IMAGE`: cAdvisor image version (default: `gcr.io/cadvisor/cadvisor:latest`)
- `CADVISOR_PORT`: cAdvisor port (default: `3102`)

### Ports

- `3102`: cAdvisor web UI and metrics (mapped from internal 8080)

### Volumes

- `/var/run/docker.sock`: Docker socket for container discovery (read-only)
- `/`: Host root filesystem (read-only)
- `/var/run`: Host runtime directory (read-only)
- `/sys`: Host sys filesystem (read-only)
- `/var/lib/docker/`: Docker data directory (read-only)
- `/dev/disk/`: Disk devices (read-only)

### Special Requirements

- `privileged: true`: Required for full system access
- `/dev/kmsg`: Kernel message device

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-cadvisor

# Access web UI
open http://localhost:3102
```

## Metrics Collected

cAdvisor collects detailed metrics for each container:

### CPU Metrics
- CPU usage (total, per-core)
- CPU throttling
- CPU load average

### Memory Metrics
- Memory usage (total, RSS, cache)
- Memory limits
- Memory failures
- Swap usage

### Network Metrics
- Network I/O (bytes, packets)
- Network errors
- Network drops

### Disk Metrics
- Disk I/O (read/write bytes, operations)
- Disk usage

### Filesystem Metrics
- Filesystem usage
- Filesystem limits
- Inode usage

## Dependencies

- Docker socket access (required)
- Host filesystem access (required)

## Dependents

- `foundation-prometheus`: Scrapes metrics from cAdvisor

## Health Check

```bash
# Check health status
docker inspect foundation-cadvisor --format='{{.State.Health.Status}}'

# Check cAdvisor health endpoint
curl http://localhost:3102/healthz
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
- Port: `8080` (internal)
- Format: Prometheus exposition format
- Auto-discovered by Prometheus via Docker labels

## Web UI

cAdvisor provides a web UI at `http://localhost:3102`:
- Real-time container metrics
- Historical graphs
- Container hierarchy
- Resource usage breakdown

## Metric Examples

```promql
# Container CPU usage
container_cpu_usage_seconds_total

# Container memory usage
container_memory_usage_bytes

# Container network received bytes
container_network_receive_bytes_total

# Container filesystem usage
container_fs_usage_bytes
```

## Performance Considerations

- cAdvisor is resource-intensive
- Collects metrics every 1 second by default
- Stores 2 minutes of historical data
- May impact host performance on systems with many containers

## Security Notes

- Requires privileged mode (security risk)
- Has access to all container data
- Has access to host filesystem
- Restrict network access to trusted services
- Use in trusted environments only
- Regular security updates via image updates

## Troubleshooting

```bash
# Check if cAdvisor can access Docker
docker logs foundation-cadvisor | grep -i error

# Check if metrics are being collected
curl http://localhost:3102/metrics | head -20

# View specific container metrics
curl http://localhost:3102/api/v1.3/containers/docker/<container-id>
```

## Alternative Configurations

For production, consider:
- Reducing metric collection frequency
- Limiting historical data retention
- Using read-only Docker socket
- Running without privileged mode (limited metrics)
