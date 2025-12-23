storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1  # TLS handled by Traefik
}

api_addr = "http://foundation-vault:8200"
cluster_addr = "http://foundation-vault:8201"

ui = true

# Enable metrics
telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}

# Logging
log_level = "info"
log_format = "json"
log_file = "/vault/logs/vault.log"

# Default lease durations
default_lease_ttl = "168h"  # 7 days
max_lease_ttl = "720h"      # 30 days
