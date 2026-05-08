# Naftiko Nist Cybersecurity Framework Sandbox

One-click container deploy of a Naftiko Framework capability that wraps the Nist Cybersecurity Framework API. Backed by mocks at [mocks.naftiko.net](https://mocks.naftiko.net) — no upstream credentials required.

## Run it

[![Run in Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/naftiko/nist-cybersecurity-framework-sandbox)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/naftiko/nist-cybersecurity-framework-sandbox)
[![Run on Google Cloud](https://deploy.cloud.run/button.svg)](https://deploy.cloud.run/?git_repo=https://github.com/naftiko/nist-cybersecurity-framework-sandbox)
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template?template=https://github.com/naftiko/nist-cybersecurity-framework-sandbox)
[![Run on Replit](https://replit.com/badge/github/naftiko/nist-cybersecurity-framework-sandbox)](https://replit.com/github/naftiko/nist-cybersecurity-framework-sandbox)

The Cloudflare button gives you the full three-protocol surface (MCP + REST + SKILL) via the bundled Worker proxy. The other four buttons expose the MCP server on port 3001 directly. See **[Per-platform behavior](#per-platform-behavior)** below.

## What this deploys

| Adapter | Path | Namespace | Tools / resources |
|---|---|---|---|
| MCP | `POST /mcp` | `nist-cybersecurity-framework-sandbox-tools` | 3 starter tools |
| REST | `/api/...` | `nist-cybersecurity-framework-sandbox-api` | 3 REST resources mirroring the MCP tools |
| SKILL | `/skill` | `nist-cybersecurity-framework-sandbox-skills` | One skill group bundling the starter tools |

Backed by:
- **Nist Cybersecurity Framework API** at `mocks.naftiko.net/rest/NIST Cybersecurity Framework (CSF) 2.0 — Sandbox API/1.0.0` — hosted in [`naftiko/sandboxes`](https://github.com/naftiko/sandboxes/tree/main/specs)

The MCP server requires a bearer token. The deploy ships a dummy `sk-mcp-YYYYYYYYYYYY` so you can wire it into a client immediately. Real deployments swap before redeploying.

## Starter scope vs. full surface

This capability bootstraps **3 representative GET operations** from the primary OpenAPI (NIST Cybersecurity Framework (CSF) 2.0 — Sandbox API). To expose more operations, edit `capability/shared/NIST Cybersecurity Framework (CSF) 2.0 — Sandbox API-consumes.yml` and `capability/nist-cybersecurity-framework-sandbox.naftiko.yml` — add a resource per OpenAPI path and a tool per operation.

## Files

| Path | What it is |
|---|---|
| `capability/nist-cybersecurity-framework-sandbox.naftiko.yml` | The Naftiko Framework capability YAML |
| `capability/shared/NIST Cybersecurity Framework (CSF) 2.0 — Sandbox API-consumes.yml` | Imported `consumes` block — points at the central Microcks mock |
| `capability/shared/secrets.yaml` | Dummy MCP server bearer token |
| `Dockerfile` | Builds on `ghcr.io/naftiko/framework:latest`, copies `capability/` into `/app/` — read by every platform |
| `wrangler.toml` | Cloudflare-only — Durable Object–backed `NistCybersecurityFrameworkSandboxContainer` |
| `src/index.ts` | Cloudflare-only — Worker proxy fronting the three engine ports |
| `render.yaml` | Render-only — Blueprint that pins `PORT=3001` to the Dockerfile |

Cloud Run, Railway, and Replit auto-detect the Dockerfile and need no extra config in the repo.

## Per-platform behavior

| Button | Public surface | Notes |
|---|---|---|
| **Cloudflare** | `/mcp` + `/api/...` + `/skill` + landing page on `/` | Worker proxies three ports through one hostname. |
| **Render** | MCP only on `PORT=3001` | Free tier with cold-starts. |
| **Google Cloud Run** | MCP only on `PORT=3001` | Scales to zero. |
| **Railway** | MCP only on the assigned hostname | Auto-detects Dockerfile. |
| **Replit** | MCP only inside the Replit container | Best for "kick the tires" exploration. |

## Local development

```sh
npm install
npm run dev
```

## Source

- OpenAPI source: <https://github.com/naftiko/sandboxes/blob/main/specs/nist-csf-2.0-sandbox-openapi.yaml>
- Naftiko Framework: <https://github.com/naftiko/framework>
- Mock host: <https://mocks.naftiko.net>
