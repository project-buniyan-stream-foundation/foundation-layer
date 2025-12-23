# Foundation Grafana Container
# Extends official Grafana image for customization
FROM grafana/grafana:latest

# Add custom plugins or dashboards if needed
# COPY plugins/ /var/lib/grafana/plugins/
# COPY dashboards/ /var/lib/grafana/dashboards/

# Set labels
LABEL tier="5" \
      component="observability" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1
