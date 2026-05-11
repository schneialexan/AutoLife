import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

import { pickRedirect, verifyOAuthState } from "./state_token.ts";

export type ExchangeTokensFn = (input: {
  connectorId: string;
  tenantId: string;
  code: string;
}) => Promise<Record<string, unknown>>;

export type OAuthCallbackEnv = {
  supabaseUrl: string;
  serviceRoleKey: string;
  stateSecret: string;
  redirectAllowlist: string[];
  exchangeTokens: ExchangeTokensFn;
  /** Test injection — otherwise a service-role client is created. */
  admin?: SupabaseClient;
};

function serviceRoleClient(env: OAuthCallbackEnv): SupabaseClient {
  return env.admin ??
    createClient(env.supabaseUrl, env.serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
    });
}

async function recordConnectorEvent(
  admin: SupabaseClient,
  row: Record<string, unknown>,
): Promise<void> {
  const { error } = await admin.from("connector_event").insert(row);
  if (error) console.error("connector_event insert failed", error.message);
}

/** Completes OAuth redirect: validates state, exchanges tokens, persists Vault secret. */
export async function handleOAuthCallback(
  req: Request,
  env: OAuthCallbackEnv,
): Promise<Response> {
  const url = new URL(req.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const nowMs = Date.now();
  const admin = serviceRoleClient(env);

  const forwardedFor = req.headers.get("x-forwarded-for");
  const userAgent = req.headers.get("user-agent");

  if (!code || !state) {
    await recordConnectorEvent(admin, {
      tenant_id: "_unknown",
      connector_id: "_oauth",
      kind: "oauth_callback",
      outcome: "failure",
      error_detail: "missing_code_or_state",
      detail: {},
      client_ip: forwardedFor,
      user_agent: userAgent,
    });
    return new Response("missing code or state", { status: 400 });
  }

  const parsed = await verifyOAuthState(state, env.stateSecret, nowMs);
  if (!parsed) {
    await recordConnectorEvent(admin, {
      tenant_id: "_unknown",
      connector_id: "_oauth",
      kind: "oauth_callback",
      outcome: "failure",
      error_detail: "invalid_state",
      detail: {},
      client_ip: forwardedFor,
      user_agent: userAgent,
    });
    return new Response("invalid state", { status: 400 });
  }

  const redirect = pickRedirect(parsed, env.redirectAllowlist);
  if (!redirect) {
    await recordConnectorEvent(admin, {
      tenant_id: parsed.tenant_id,
      connector_id: parsed.connector_id,
      kind: "oauth_callback",
      outcome: "failure",
      error_detail: "redirect_not_allowed",
      detail: {},
      client_ip: forwardedFor,
      user_agent: userAgent,
    });
    return new Response("redirect not allowed", { status: 400 });
  }

  let tokens: Record<string, unknown>;
  try {
    tokens = await env.exchangeTokens({
      connectorId: parsed.connector_id,
      tenantId: parsed.tenant_id,
      code,
    });
  } catch (e) {
    await recordConnectorEvent(admin, {
      tenant_id: parsed.tenant_id,
      connector_id: parsed.connector_id,
      kind: "oauth_callback",
      outcome: "failure",
      error_detail: String(e),
      detail: {},
      client_ip: forwardedFor,
      user_agent: userAgent,
    });
    return Response.redirect(`${redirect}?oauth=error`, 302);
  }

  const { error: rpcErr } = await admin.rpc(
    "integration_store_connector_secret",
    {
      p_tenant_id: parsed.tenant_id,
      p_connector_id: parsed.connector_id,
      p_secret_json: tokens,
      p_direction: "two_way",
    },
  );

  if (rpcErr) {
    await recordConnectorEvent(admin, {
      tenant_id: parsed.tenant_id,
      connector_id: parsed.connector_id,
      kind: "oauth_callback",
      outcome: "failure",
      error_detail: rpcErr.message,
      detail: {},
      client_ip: forwardedFor,
      user_agent: userAgent,
    });
    return Response.redirect(`${redirect}?oauth=error`, 302);
  }

  await recordConnectorEvent(admin, {
    tenant_id: parsed.tenant_id,
    connector_id: parsed.connector_id,
    kind: "oauth_callback",
    outcome: "success",
    detail: { encrypted: true },
    client_ip: forwardedFor,
    user_agent: userAgent,
  });

  return Response.redirect(`${redirect}?oauth=ok`, 302);
}
