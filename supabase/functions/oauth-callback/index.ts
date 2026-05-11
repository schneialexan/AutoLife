import { handleOAuthCallback } from "./handler.ts";
import { mockConnectorTokens } from "./token_exchange.ts";

function parseAllowlist(raw: string | undefined): string[] {
  if (!raw) return [];
  return raw.split(",").map((s) => s.trim()).filter(Boolean);
}

Deno.serve(async (req) => {
  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const secret = Deno.env.get("OAUTH_STATE_SECRET") ?? "";
  const allow = parseAllowlist(Deno.env.get("OAUTH_SUCCESS_REDIRECT_ALLOWLIST"));
  if (!url || !key || !secret || allow.length === 0) {
    return new Response("oauth callback misconfigured", { status: 500 });
  }
  return handleOAuthCallback(req, {
    supabaseUrl: url,
    serviceRoleKey: key,
    stateSecret: secret,
    redirectAllowlist: allow,
    exchangeTokens: mockConnectorTokens,
  });
});
