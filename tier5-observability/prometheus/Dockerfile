# Foundation Prometheus Container
# Extends official Prometheus image for customization
FROM prom/prometheus:latest

# Add custom exporters or configurations if needed
# COPY exporters/ /exporters/

# Set labels
LABEL tier="5" \
      component="observability" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9090/-/healthy || exit 1
