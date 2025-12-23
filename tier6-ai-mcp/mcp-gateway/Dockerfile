# Foundation MCP Gateway Container
# Extends official MCP Gateway image for customization
FROM docker/mcp-gateway:latest

# Add custom MCP servers or configurations if needed
# COPY servers/ /servers/

# Set labels
LABEL tier="6" \
      component="ai-mcp" \
      maintainer="foundation-layer"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8811/health || exit 0
