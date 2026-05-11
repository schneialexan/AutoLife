import { assertEquals } from "jsr:@std/assert@1";
import { handleBootstrap } from "./index.ts";

function fakeJwt(payload: Record<string, unknown>): string {
  const body = btoa(JSON.stringify(payload));
  return `stub.${body}.stub`;
}

Deno.test("bootstrap without Authorization returns 200 with null user", async () => {
  const res = await handleBootstrap(new Request("http://local/"));
  assertEquals(res.status, 200);
  const json = await res.json() as { user: unknown; tenant: unknown };
  assertEquals(json.user, null);
  assertEquals(json.tenant, null);
});

Deno.test("bootstrap echoes JWT payload as auth context", async () => {
  const token = fakeJwt({
    sub: "user-1",
    email: "demo@example.com",
    role: "authenticated",
    app_metadata: { tenant_id: "11111111-1111-1111-1111-111111111111" },
  });
  const res = await handleBootstrap(
    new Request("http://local/", {
      headers: { Authorization: `Bearer ${token}` },
    }),
  );
  assertEquals(res.status, 200);
  const json = await res.json() as {
    user: { sub: string };
    tenant: { tenant_id: string };
  };
  assertEquals(json.user.sub, "user-1");
  assertEquals(json.tenant.tenant_id, "11111111-1111-1111-1111-111111111111");
});
