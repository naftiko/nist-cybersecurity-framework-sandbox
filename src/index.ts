import { Container, getContainer } from "@cloudflare/containers";

interface Env {
  NIST_CYBERSECURITY_FRAMEWORK_SANDBOX: DurableObjectNamespace<NistCybersecurityFrameworkSandboxContainer>;
}

const MCP_PORT = 3001;
const REST_PORT = 3002;
const SKILL_PORT = 3003;

export class NistCybersecurityFrameworkSandboxContainer extends Container<Env> {
  defaultPort = REST_PORT;
  requiredPorts = [MCP_PORT, REST_PORT, SKILL_PORT];
  sleepAfter = "10m";

  override async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    if (path === "/mcp" || path.startsWith("/mcp/")) {
      const rewritten = new URL(request.url);
      rewritten.pathname = path === "/mcp" ? "/" : path.slice("/mcp".length);
      const proxied = new Request(rewritten.toString(), request);
      return super.containerFetch(proxied, MCP_PORT);
    }

    if (path === "/skill" || path.startsWith("/skill/")) {
      const rewritten = new URL(request.url);
      rewritten.pathname = path === "/skill" ? "/" : path.slice("/skill".length);
      const proxied = new Request(rewritten.toString(), request);
      return super.containerFetch(proxied, SKILL_PORT);
    }

    return super.containerFetch(request, REST_PORT);
  }

  override async onStart(): Promise<void> {
    console.log(`Naftiko Nist Cybersecurity Framework Sandbox ready — MCP on ${MCP_PORT}, REST on ${REST_PORT}, SKILL on ${SKILL_PORT}.`);
  }

  override onStop(): void {
    console.log("Naftiko Nist Cybersecurity Framework Sandbox container stopped.");
  }

  override onError(error: unknown): void {
    console.error("Naftiko Nist Cybersecurity Framework Sandbox container error:", error);
  }
}

function landing(): Response {
  const body = `Naftiko Nist Cybersecurity Framework Sandbox

Naftiko Framework engine wrapping the Nist Cybersecurity Framework API mocks at
mocks.naftiko.net (no real upstream credentials needed).

MCP endpoint:
  POST /mcp                   — namespace: nist-cybersecurity-framework-sandbox-tools

REST endpoint:
  /api/...                    — namespace: nist-cybersecurity-framework-sandbox-api

SKILL endpoint:
  /skill                      — namespace: nist-cybersecurity-framework-sandbox-skills

Source:    https://github.com/naftiko/nist-cybersecurity-framework-sandbox
Mocks:     https://mocks.naftiko.net
Framework: https://github.com/naftiko/framework
`;
  return new Response(body, {
    status: 200,
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === "/" || url.pathname === "") {
      return landing();
    }
    const container = getContainer(env.NIST_CYBERSECURITY_FRAMEWORK_SANDBOX);
    return container.fetch(request);
  },
};
