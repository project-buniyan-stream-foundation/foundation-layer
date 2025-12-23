# Foundation Traefik Container
# Extends official Traefik image for customization
FROM traefik:v2.10

# Add custom plugins or configurations if needed
# COPY plugins/ /plugins/

# Set labels
LABEL tier="2" \
      component="proxy" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=10s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ping || \
      wget --no-verbose --tries=1 --spider http://localhost:8080/api/rawdata || exit 1
