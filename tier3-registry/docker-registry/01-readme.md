# Docker Registry Container

**Tier**: 3 - Registry  
**Component**: Docker Image Registry  
**Purpose**: Private Docker image registry for foundation and project images

## Overview

This container provides a private Docker registry for storing and distributing Docker images.

## Configuration

### Environment Variables

- `REGISTRY_IMAGE`: Registry image version (default: `registry:2`)
- `REGISTRY_PORT`: Registry port (default: `5000`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `5000`: Registry HTTP API

### Volumes

- `${DOCKER_STORAGE_ROOT}/foundation/docker-registry/data/`: Registry data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-tier3-registry

# Test registry
curl http://localhost:5000/v2/_catalog
```

## Usage

```bash
# Tag an image for this registry
docker tag myimage:latest localhost:5000/myimage:latest

# Push to registry
docker push localhost:5000/myimage:latest

# Pull from registry
docker pull localhost:5000/myimage:latest
```

## Labels

- `tier=3`
- `component=registry`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://registry.local`
- Requires Keycloak authentication
- Service: `registry`
- Port: `5000`
