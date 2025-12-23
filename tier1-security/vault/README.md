# HashiCorp Vault Container

**Tier**: 1 - Security  
**Component**: Secrets Management  
**Purpose**: Centralized secrets management for all foundation and project services

## Overview

This container provides HashiCorp Vault for secure secrets storage and management across the entire foundation layer.

## Configuration

### Environment Variables

- `VAULT_ADDR`: Vault API address (default: `http://0.0.0.0:8200`)
- `VAULT_API_ADDR`: Vault API address for cluster (default: `http://foundation-vault:8200`)
- `VAULT_LOG_LEVEL`: Log level (default: `info`)
- `DOCKER_STORAGE_ROOT`: Storage root path (default: `/docker-storage`)

### Ports

- `8200`: Vault API and UI port

### Volumes

- `./config/vault.hcl`: Vault configuration (read-only)
- `./config/policies/`: Vault policies (read-only)
- `${DOCKER_STORAGE_ROOT}/foundation/vault/data/`: Vault data (read-write)
- `${DOCKER_STORAGE_ROOT}/foundation/vault/logs/`: Vault logs (read-write)

## Deployment

```bash
# Deploy standalone
docker compose up -d

# View logs
docker logs foundation-vault

# Access Vault UI
open http://localhost:8200/ui
```

## Initialization

After first deployment, Vault must be initialized and unsealed:

```bash
# Initialize Vault (run once)
docker exec foundation-vault vault operator init

# Unseal Vault (required after each restart)
docker exec foundation-vault vault operator unseal <unseal-key-1>
docker exec foundation-vault vault operator unseal <unseal-key-2>
docker exec foundation-vault vault operator unseal <unseal-key-3>
```

## Health Check

```bash
# Check health status
docker inspect foundation-vault --format='{{.State.Health.Status}}'

# Check Vault status
docker exec foundation-vault vault status
```

## Dependencies

- None (this is a foundational service)

## Dependents

- All foundation services that require secrets
- All project services that require secrets

## Labels

- `tier=1`
- `component=security`
- `portfolio=portfolio-bunyan`
- `layer=foundation-layer`
- `project=stream-foundation`
- `network=foundation-layer-network`

## Traefik Integration

- Accessible via: `http://vault.local`
- Service: `vault`
- Port: `8200`

## Prometheus Integration

- Metrics endpoint: `/v1/sys/metrics?format=prometheus`
- Port: `8200`

## Security Notes

- Store unseal keys securely (never commit to git)
- Use auto-unseal in production
- Enable TLS in production
- Rotate secrets regularly
- Audit all secret access
