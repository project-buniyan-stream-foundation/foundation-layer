# Foundation Keycloak Container
# Extends official Keycloak image for customization
FROM quay.io/keycloak/keycloak:26.4.7

# Add custom themes or providers if needed
# COPY themes/ /opt/keycloak/themes/
# COPY providers/ /opt/keycloak/providers/

# Set labels
LABEL tier="1" \
      component="security" \
      maintainer="foundation-layer"

# Note: Keycloak doesn't have built-in health check tools
# Health check is handled via external monitoring
