FROM --platform=linux/amd64 ghcr.io/naftiko/framework:latest

LABEL deploy.timestamp="20260508-v1"

# Cloudflare Containers route to 10.0.0.1, not localhost. The capability YAML
# binds MCP/REST/SKILL to 0.0.0.0 so the engine listens on all interfaces.
COPY capability/ /app/

EXPOSE 3001 3002 3003

CMD ["/app/nist-cybersecurity-framework-sandbox.naftiko.yml"]
