# Policy for Foundation Services
# Allows services to read their own secrets

# Keycloak can read its own secrets
path "secret/data/keycloak/*" {
  capabilities = ["read"]
}

# Grafana can read its secrets
path "secret/data/grafana" {
  capabilities = ["read"]
}
path "secret/data/keycloak/clients/grafana" {
  capabilities = ["read"]
}

# Portainer can read its secrets
path "secret/data/portainer" {
  capabilities = ["read"]
}
path "secret/data/keycloak/clients/portainer" {
  capabilities = ["read"]
}

# MCP Gateway can read its secrets
path "secret/data/mcp-gateway" {
  capabilities = ["read"]
}
path "secret/data/keycloak/clients/mcp-gateway" {
  capabilities = ["read"]
}

# Traefik can read its secrets
path "secret/data/traefik" {
  capabilities = ["read"]
}
path "secret/data/keycloak/clients/traefik" {
  capabilities = ["read"]
}
