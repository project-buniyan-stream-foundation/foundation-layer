# Foundation cAdvisor Container
# Extends official cAdvisor image for customization
FROM gcr.io/cadvisor/cadvisor:latest

# Add custom configurations if needed
# COPY config/ /config/

# Set labels
LABEL tier="5" \
      component="observability" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/healthz || exit 1
