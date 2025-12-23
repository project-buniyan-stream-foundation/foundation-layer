# Foundation PostgreSQL Container
# Extends official PostgreSQL image for customization
FROM postgres:15-alpine

# Add custom initialization scripts if needed
# COPY custom-scripts/ /docker-entrypoint-initdb.d/

# Set labels
LABEL tier="1" \
      component="database" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=30s \
  CMD pg_isready -U ${POSTGRES_USER:-keycloak} || exit 1
