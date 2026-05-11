import { assertEquals, assertStringIncludes } from "jsr:@std/assert@1";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { handleOAuthCallback } from "../handler.ts";
import { mockConnectorTokens } from "../token_exchange.ts";
import { signOAuthState } from "../state_token.ts";

function stubAdmin(params: {
  rpcResult?: { error: { message: string } | null };
}): SupabaseClient {
  const admin = {
    rpc: async (_fn: string, _args: Record<string, unknown>) => ({
      error: params.rpcResult?.error ?? null,
    }),
    from: (_table: string) => ({
      insert: async (_row: Record<string, unknown>) => ({ error: null }),
    }),
  };
  return admin as unknown as SupabaseClient;
}

Deno.test("oauth handler succeeds for mock connector (vault RPC stubbed)", async () => {
  const secret = "handler-secret";
  const exp = Math.floor(Date.now() / 1000) + 120;
  const state = await signOAuthState(
    {
      tenant_id: "tenant-z",
      connector_id: "mock",
      exp,
      redirect_success: "https://allowed.example/finish",
    },
    secret,
  );

  const inserts: Record<string, unknown>[] = [];
  let rpcCalls = 0;
  const admin = {
    rpc: async (_fn: string, _args: Record<string, unknown>) => {
      rpcCalls++;
      return { error: null };
    },
    from: (_table: string) => ({
      insert: async (row: Record<string, unknown>) => {
        inserts.push(row);
        return { error: null };
      },
    }),
  } as unknown as SupabaseClient;

  const req = new Request(
    `https://oauth/callback?code=fake-code&state=${encodeURIComponent(state)}`,
    { headers: { "user-agent": "jest-ish", "x-forwarded-for": "203.0.113.1" } },
  );

  const res = await handleOAuthCallback(req, {
    supabaseUrl: "http://local.test",
    serviceRoleKey: "service-role",
    stateSecret: secret,
    redirectAllowlist: ["https://allowed.example"],
    exchangeTokens: mockConnectorTokens,
    admin,
  });

  assertEquals(res.status, 302);
  assertStringIncludes(res.headers.get("Location") ?? "", "https://allowed.example/finish");
  assertStringIncludes(res.headers.get("Location") ?? "", "oauth=ok");
  assertEquals(rpcCalls, 1);

  const oauthRows = inserts.filter((r) => r["kind"] === "oauth_callback");
  assertEquals(oauthRows.length >= 1, true);
  const successRow = oauthRows.find((r) => r["outcome"] === "success");
  assertEquals(successRow?.["tenant_id"], "tenant-z");
  assertEquals(successRow?.["connector_id"], "mock");
});

Deno.test("oauth handler redirects error when vault RPC fails", async () => {
  const secret = "handler-secret";
  const exp = Math.floor(Date.now() / 1000) + 120;
  const state = await signOAuthState(
    {
      tenant_id: "tenant-z",
      connector_id: "mock",
      exp,
      redirect_success: "https://allowed.example/finish",
    },
    secret,
  );

  const admin = stubAdmin({
    rpcResult: { error: { message: "vault broken" } },
  });

  const req = new Request(
    `https://oauth/callback?code=fake-code&state=${encodeURIComponent(state)}`,
  );

  const res = await handleOAuthCallback(req, {
    supabaseUrl: "http://local.test",
    serviceRoleKey: "service-role",
    stateSecret: secret,
    redirectAllowlist: ["https://allowed.example"],
    exchangeTokens: mockConnectorTokens,
    admin,
  });

  assertEquals(res.status, 302);
  assertStringIncludes(res.headers.get("Location") ?? "", "oauth=error");
});
