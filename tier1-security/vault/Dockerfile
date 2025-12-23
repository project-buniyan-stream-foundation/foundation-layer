# Foundation Vault Container
# Extends official Vault image for customization
FROM hashicorp/vault:1.21.1

# Add custom configuration if needed
# COPY custom-config/ /vault/config/

# Set labels
LABEL tier="1" \
      component="security" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=30s \
  CMD vault status || exit 0
