# Foundation Docker Registry Container
# Extends official Registry image for customization
FROM registry:2

# Add custom middleware or configurations if needed
# COPY middleware/ /middleware/

# Set labels
LABEL tier="3" \
      component="registry" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/v2/ || exit 1
