# Verdaccio Container

**Tier**: 3 - Registry  
**Component**: NPM Package Registry  
**Purpose**: Private NPM registry for foundation and project packages

## Overview

This container provides Verdaccio as a private NPM registry for storing and distributing Node.js packages.

## Configuration

### Environment Variables

- `VERDACCIO_IMAGE`: Verdaccio image version (default: `verdaccio/verdaccio:latest`)
- `VERDACCIO_PORT`: Verdaccio port (default: `4873`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `4873`: Verdaccio HTTP API

### Volumes

- `./config/config.yaml`: Verdaccio configuration (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/verdaccio/storage/`: Package storage (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-verdaccio

# Access web UI
open http://localhost:4873
```

## Usage

```bash
# Configure npm to use this registry
npm set registry http://localhost:4873

# Publish a package
npm publish

# Install from registry
npm install mypackage
```

## Labels

- `tier=3`
- `component=registry`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://verdaccio.local`
- Requires Keycloak authentication
- Service: `verdaccio`
- Port: `4873`
