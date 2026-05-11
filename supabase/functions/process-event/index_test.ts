import { assertEquals } from "jsr:@std/assert@1";

import { handleProcessEvent } from "./handler.ts";

async function withStubSupabaseEnv(fn: () => Promise<void>): Promise<void> {
  const keys = [
    ["SUPABASE_URL", "http://127.0.0.1:54321"],
    ["SUPABASE_SERVICE_ROLE_KEY", "stub_service_role"],
  ] as const;

  const previous = new Map<string, string | undefined>();
  for (const [k, v] of keys) {
    previous.set(k, Deno.env.get(k));
    Deno.env.set(k, v);
  }

  try {
    await fn();
  } finally {
    for (const [k] of keys) {
      const prior = previous.get(k);
      if (prior === undefined) Deno.env.delete(k);
      else Deno.env.set(k, prior);
    }
  }
}

Deno.test("non-POST returns 405", async () => {
  const res = await handleProcessEvent(
    new Request("http://local/", { method: "GET" }),
  );
  assertEquals(res.status, 405);
});

Deno.test("POST without Supabase env returns 500", async () => {
  const prevUrl = Deno.env.get("SUPABASE_URL");
  const prevKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  try {
    Deno.env.delete("SUPABASE_URL");
    Deno.env.delete("SUPABASE_SERVICE_ROLE_KEY");
    const res = await handleProcessEvent(
      new Request("http://local/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: "{}",
      }),
    );
    assertEquals(res.status, 500);
  } finally {
    if (prevUrl !== undefined) Deno.env.set("SUPABASE_URL", prevUrl);
    if (prevKey !== undefined) {
      Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", prevKey);
    }
  }
});

Deno.test("POST without event_id returns 400 (with stub Supabase env)", async () => {
  await withStubSupabaseEnv(async () => {
    const res = await handleProcessEvent(
      new Request("http://local/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({}),
      }),
    );
    assertEquals(res.status, 400);
  });
});
