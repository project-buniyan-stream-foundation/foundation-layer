# Foundation Portainer Container
# Extends official Portainer image for customization
FROM portainer/portainer-ce:latest

# Add custom templates if needed
# COPY templates/ /templates/

# Set labels
LABEL tier="4" \
      component="management" \
      maintainer="foundation-layer"

# Note: Portainer is a minimal Go binary without shell tools
# Health check is handled via external monitoring
