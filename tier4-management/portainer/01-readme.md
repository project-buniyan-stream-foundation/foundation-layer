# Portainer Container

**Tier**: 4 - Management  
**Component**: Container Management UI  
**Purpose**: Web-based Docker container management interface

## Overview

This container provides Portainer for managing Docker containers, images, networks, and volumes through a web interface.

## Configuration

### Environment Variables

- `PORTAINER_IMAGE`: Portainer image version (default: `portainer/portainer-ce:latest`)
- `PORTAINER_HTTP_PORT`: HTTP port (default: `3103`)
- `PORTAINER_HTTPS_PORT`: HTTPS port (default: `9443`)
- `PORTAINER_EDGE_PORT`: Edge agent port (default: `8000`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `3103`: Portainer web UI (mapped from internal 9000)
- `9443`: Portainer HTTPS
- `8000`: Edge agent (TCP tunnel)

### Volumes

- `/var/run/docker.sock`: Docker socket for management (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/portainer/data/`: Portainer data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-portainer

# Access web UI
open http://localhost:3103
```

## Initial Setup

On first access, you must create an admin user within 5 minutes or the container will timeout for security.

## Labels

- `tier=4`
- `component=management`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://portainer.local`
- Requires Keycloak authentication
- Service: `portainer`
- Port: `9000` (internal)

## Security Notes

- Create admin user immediately after first deployment
- Use strong passwords
- Enable 2FA in production
- Restrict Docker socket access
- Regular security updates
