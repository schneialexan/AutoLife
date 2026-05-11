function parseBearerToken(req: Request): string | null {
  const header = req.headers.get("Authorization");
  if (header === null || !header.startsWith("Bearer ")) return null;
  return header.slice(7);
}

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  try {
    const b64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const pad = "=".repeat((4 - (b64.length % 4)) % 4);
    const json = atob(b64 + pad);
    return JSON.parse(json) as Record<string, unknown>;
  } catch {
    return null;
  }
}

export async function handleBootstrap(req: Request): Promise<Response> {
  const token = parseBearerToken(req);
  const payload = token !== null ? decodeJwtPayload(token) : null;

  const appMeta = payload?.["app_metadata"] as
    | Record<string, unknown>
    | undefined;
  const userMeta = payload?.["user_metadata"] as
    | Record<string, unknown>
    | undefined;
  const tenantRaw = appMeta?.["tenant_id"] ?? userMeta?.["tenant_id"];

  const body = {
    user: payload !== null
      ? {
        sub: payload["sub"] ?? null,
        email: payload["email"] ?? null,
        role: payload["role"] ?? null,
      }
      : null,
    tenant: tenantRaw !== undefined && tenantRaw !== null
      ? { tenant_id: tenantRaw }
      : null,
  };

  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(handleBootstrap);
