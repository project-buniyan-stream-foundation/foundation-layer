# MCP Gateway Container

**Tier**: 6 - AI-MCP  
**Component**: AI Tool Integration  
**Purpose**: Model Context Protocol gateway for AI tool integration

## Overview

This container provides the MCP Gateway for integrating AI tools and services with the foundation layer.

## Configuration

### Environment Variables

- `MCP_GATEWAY_IMAGE`: MCP Gateway image version (default: `docker/mcp-gateway:latest`)
- `MCP_GATEWAY_PORT`: Gateway port (default: `8811`)
- `DOCKER_MCP_USE_CE`: Use Community Edition (default: `true`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `8811`: MCP Gateway SSE endpoint

### Volumes

- `/var/run/docker.sock`: Docker socket for MCP server (read-only)
- `./config/mcp-gateway-config.yaml`: Gateway configuration (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/mcp-gateway/data/`: Gateway data (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-mcp-gateway

# Check health
curl http://localhost:8811/health
```

## Labels

- `tier=6`
- `component=ai-mcp`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://mcp.local`
- Requires Keycloak authentication
- Service: `mcp-gateway`
- Port: `8811`

## SSE Protocol

MCP Gateway uses Server-Sent Events (SSE) protocol. Access via:
- Health: `http://localhost:8811/health`
- Servers: `http://localhost:8811/servers`
- SSE Stream: `http://localhost:8811/sse`
