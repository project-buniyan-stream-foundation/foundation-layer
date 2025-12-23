# Policy Template for Projects
# Each project gets a similar policy with project-specific paths

# Project can read its own secrets
path "secret/data/project-{project-name}/*" {
  capabilities = ["read", "list"]
}

# Project can read its Keycloak client secret
path "secret/data/keycloak/clients/project-{project-name}" {
  capabilities = ["read"]
}

# Project cannot access other projects' secrets
path "secret/data/project-*" {
  capabilities = ["deny"]
}

# Project cannot access foundation secrets
path "secret/data/foundation/*" {
  capabilities = ["deny"]
}
