# Foundation Loki Container
# Extends official Loki image for customization
FROM grafana/loki:latest

# Add custom plugins or configurations if needed
# COPY plugins/ /plugins/

# Set labels
LABEL tier="5" \
      component="observability" \
      maintainer="foundation-layer"

# Note: Loki is a minimal Go binary without shell tools
# Health check is handled via external monitoring
