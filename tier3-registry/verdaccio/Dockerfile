# Foundation Verdaccio Container
# Extends official Verdaccio image for customization
FROM verdaccio/verdaccio:latest

# Add custom plugins if needed
# COPY plugins/ /verdaccio/plugins/

# Set labels
LABEL tier="3" \
      component="registry" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=5 --start-period=60s \
  CMD wget --spider http://127.0.0.1:4873/ || exit 1
