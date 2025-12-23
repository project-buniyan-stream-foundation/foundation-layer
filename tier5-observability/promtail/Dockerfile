# Foundation Promtail Container
# Extends official Promtail image for customization
FROM grafana/promtail:latest

# Add custom plugins or configurations if needed
# COPY plugins/ /plugins/

# Set labels
LABEL tier="5" \
      component="observability" \
      maintainer="foundation-layer"

# Note: Promtail doesn't expose health check endpoint
# Health check is handled via external monitoring
