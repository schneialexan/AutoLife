const enc = new TextEncoder();

export type OAuthStatePayload = {
  tenant_id: string;
  connector_id: string;
  redirect_success?: string;
  exp: number;
};

function base64UrlEncode(bytes: Uint8Array): string {
  let bin = "";
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]!);
  const b64 = btoa(bin);
  return b64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function base64UrlDecode(s: string): Uint8Array {
  const pad = "=".repeat((4 - (s.length % 4)) % 4);
  const b64 = s.replace(/-/g, "+").replace(/_/g, "/") + pad;
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

async function hmacSha256B64Url(secret: string, msg: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    enc.encode(msg),
  );
  return base64UrlEncode(new Uint8Array(sig));
}

/** Builds an HMAC state parameter consumed by `oauth-callback`. */
export async function signOAuthState(
  payload: OAuthStatePayload,
  secret: string,
): Promise<string> {
  const json = JSON.stringify(payload);
  const payloadB64 = base64UrlEncode(enc.encode(json));
  const sig = await hmacSha256B64Url(secret, payloadB64);
  return `${payloadB64}.${sig}`;
}

/** Validates signature + expiry on OAuth state. */
export async function verifyOAuthState(
  state: string,
  secret: string,
  nowMs: number,
): Promise<OAuthStatePayload | null> {
  const lastDot = state.lastIndexOf(".");
  if (lastDot <= 0) return null;
  const payloadB64 = state.slice(0, lastDot);
  const sig = state.slice(lastDot + 1);
  const expected = await hmacSha256B64Url(secret, payloadB64);
  if (expected !== sig) return null;

  let raw: unknown;
  try {
    raw = JSON.parse(new TextDecoder().decode(base64UrlDecode(payloadB64)));
  } catch {
    return null;
  }
  if (typeof raw !== "object" || raw === null) return null;
  const o = raw as Record<string, unknown>;
  const tenant_id = o["tenant_id"];
  const connector_id = o["connector_id"];
  const exp = o["exp"];
  if (typeof tenant_id !== "string" || typeof connector_id !== "string") {
    return null;
  }
  if (typeof exp !== "number" || exp * 1000 < nowMs) return null;
  const redirect_success = o["redirect_success"];
  return {
    tenant_id,
    connector_id,
    exp,
    redirect_success: typeof redirect_success === "string"
      ? redirect_success
      : undefined,
  };
}

/** Returns redirect URL only when allow-listed as a prefix. */
export function pickRedirect(
  payload: OAuthStatePayload,
  allowlist: string[],
): string | null {
  const candidate = payload.redirect_success ?? allowlist[0];
  if (!candidate) return null;
  return allowlist.some((p) => candidate.startsWith(p)) ? candidate : null;
}
