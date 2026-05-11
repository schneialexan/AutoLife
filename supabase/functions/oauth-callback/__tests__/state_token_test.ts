import { assertEquals } from "jsr:@std/assert@1";
import {
  pickRedirect,
  signOAuthState,
  verifyOAuthState,
  type OAuthStatePayload,
} from "../state_token.ts";

Deno.test("sign + verify roundtrip", async () => {
  const payload: OAuthStatePayload = {
    tenant_id: "tenant-a",
    connector_id: "mock",
    exp: Math.floor(Date.now() / 1000) + 120,
    redirect_success: "https://app.example/oauth/done",
  };
  const secret = "unit-test-secret";
  const state = await signOAuthState(payload, secret);
  const parsed = await verifyOAuthState(state, secret, Date.now());
  assertEquals(parsed?.tenant_id, "tenant-a");
  assertEquals(parsed?.connector_id, "mock");
  assertEquals(parsed?.redirect_success, payload.redirect_success);
});

Deno.test("tampered state fails verification", async () => {
  const payload: OAuthStatePayload = {
    tenant_id: "tenant-a",
    connector_id: "mock",
    exp: Math.floor(Date.now() / 1000) + 120,
  };
  const state = await signOAuthState(payload, "secret");
  const tampered = `${state.slice(0, -4)}xxxx`;
  const parsed = await verifyOAuthState(tampered, "secret", Date.now());
  assertEquals(parsed, null);
});

Deno.test("expired state rejected", async () => {
  const payload: OAuthStatePayload = {
    tenant_id: "tenant-a",
    connector_id: "mock",
    exp: Math.floor(Date.now() / 1000) - 10,
  };
  const state = await signOAuthState(payload, "secret");
  const parsed = await verifyOAuthState(state, "secret", Date.now());
  assertEquals(parsed, null);
});

Deno.test("pickRedirect honors allowlist", () => {
  const payload: OAuthStatePayload = {
    tenant_id: "t",
    connector_id: "mock",
    exp: 9999999999,
    redirect_success: "https://good.example/cb",
  };
  assertEquals(
    pickRedirect(payload, ["https://good.example", "https://other"]),
    "https://good.example/cb",
  );
  assertEquals(pickRedirect(payload, ["https://evil.example"]), null);
});
