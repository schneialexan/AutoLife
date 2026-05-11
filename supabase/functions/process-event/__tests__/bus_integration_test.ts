import { assertEquals, assertExists } from "jsr:@std/assert@1";
import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";
import { clearConsumers, registerConsumer } from "../registry.ts";
import { runProcessEventWorker } from "../worker.ts";

function envReady(): boolean {
  return Boolean(
    Deno.env.get("SUPABASE_URL") && Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
  );
}

async function wipeQueue(admin: SupabaseClient) {
  await admin.from("event_delivery").delete().neq(
    "id",
    "00000000-0000-0000-0000-000000000000",
  );
  await admin.from("system_event").delete().neq(
    "id",
    "00000000-0000-0000-0000-000000000000",
  );
}

async function unstickPending(admin: SupabaseClient) {
  await admin.from("event_delivery").update({
    next_attempt_at: new Date().toISOString(),
  }).eq("status", "pending");
}

function baseEvent(overrides: Record<string, unknown> = {}) {
  return {
    tenant_id: "t-bus",
    actor_id: "a1",
    module: "test",
    type: "test.event",
    payload: {},
    idempotency_key: crypto.randomUUID(),
    occurred_at: new Date().toISOString(),
    ordering_tag: "t-bus:ord1",
    schema_version: 1,
    ...overrides,
  };
}

Deno.test({
  name: "happy path: one delivery succeeds",
  ignore: !envReady(),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  clearConsumers();
  registerConsumer("test.happy", async () => ({ ok: true }));
  await wipeQueue(admin);

  const row = baseEvent();
  const { data: ins, error } = await admin.from("system_event").insert(row)
    .select().single();
  assertEquals(error, null);
  assertExists(ins);
  await runProcessEventWorker(admin, { hintEventId: ins.id });
  const { data: del } = await admin.from("event_delivery").select("*").eq(
    "event_id",
    ins.id,
  ).maybeSingle();
  assertExists(del);
  assertEquals(del.status, "succeeded");
  assertEquals(del.attempt, 1);
});

Deno.test({
  name: "retry then success on 5th try",
  ignore: !envReady(),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  clearConsumers();
  let calls = 0;
  registerConsumer("test.retry", async () => {
    calls++;
    if (calls < 5) return { ok: false, error: `fail-${calls}` };
    return { ok: true };
  });
  await wipeQueue(admin);

  const row = baseEvent();
  const { data: ins } = await admin.from("system_event").insert(row).select()
    .single();
  assertExists(ins);

  for (let i = 0; i < 30; i++) {
    await unstickPending(admin);
    await runProcessEventWorker(admin, { hintEventId: ins.id });
    const { data: del } = await admin.from("event_delivery").select("*").eq(
      "event_id",
      ins.id,
    ).maybeSingle();
    if (del?.status === "succeeded") {
      assertEquals(del.attempt, 5);
      assertEquals(calls, 5);
      return;
    }
  }
  throw new Error("expected success by 5th attempt");
});

Deno.test({
  name: "retry then dead letter after 5 failures",
  ignore: !envReady(),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  clearConsumers();
  registerConsumer("test.dlq", async () => ({ ok: false, error: "nope" }));
  await wipeQueue(admin);

  const row = baseEvent();
  const { data: ins } = await admin.from("system_event").insert(row).select()
    .single();
  assertExists(ins);

  for (let i = 0; i < 40; i++) {
    await unstickPending(admin);
    await runProcessEventWorker(admin, { hintEventId: ins.id });
    const { data: del } = await admin.from("event_delivery").select("*").eq(
      "event_id",
      ins.id,
    ).maybeSingle();
    if (del?.status === "dead_letter") {
      assertEquals(del.attempt, 5);
      const { data: view } = await admin.from("dead_letter_event").select(
        "delivery_id",
      ).eq("delivery_id", del.id).maybeSingle();
      assertExists(view);
      return;
    }
  }
  throw new Error("expected dead_letter");
});

Deno.test({
  name: "idempotent insert: one system_event row for duplicate keys",
  ignore: !envReady(),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  await wipeQueue(admin);
  const idem = "shared-idem-key";
  const row = baseEvent({ idempotency_key: idem });
  const { data: first, error: e1 } = await admin.from("system_event").insert(
    row,
  ).select().single();
  assertEquals(e1, null);
  assertExists(first);
  const { error: e2 } = await admin.from("system_event").insert(row).select();
  assertExists(e2);

  const { data: rows, error: e3 } = await admin.from("system_event").select(
    "id",
  ).eq("tenant_id", "t-bus").eq("idempotency_key", idem);
  assertEquals(e3, null);
  assertEquals(rows?.length, 1);
});

Deno.test({
  name: "ordering: same ordering_tag processed in occurred_at order",
  ignore: !envReady(),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  clearConsumers();
  const order: string[] = [];
  registerConsumer("test.order", async (ev) => {
    order.push(ev.id);
    return { ok: true };
  });
  await wipeQueue(admin);

  const tag = "t-bus:lock";
  const early = baseEvent({
    idempotency_key: "ord-a",
    ordering_tag: tag,
    occurred_at: new Date("2019-01-01T00:00:00.000Z").toISOString(),
  });
  const late = baseEvent({
    idempotency_key: "ord-b",
    ordering_tag: tag,
    occurred_at: new Date("2019-06-01T00:00:00.000Z").toISOString(),
  });
  const { data: e1 } = await admin.from("system_event").insert(early).select()
    .single();
  const { data: e2 } = await admin.from("system_event").insert(late).select()
    .single();
  assertExists(e1);
  assertExists(e2);

  for (let i = 0; i < 50; i++) {
    if (order.length >= 2) break;
    await new Promise((r) => setTimeout(r, 100));
  }
  const i1 = order.indexOf(e1.id);
  const i2 = order.indexOf(e2.id);
  assertEquals(i1 >= 0 && i2 >= 0 && i1 < i2, true);
});

Deno.test({
  name: "concurrent workers preserve ordering with SUPABASE_DB_DIRECT_URL",
  ignore: !envReady() || !Deno.env.get("SUPABASE_DB_DIRECT_URL"),
  sanitizeOps: false,
  sanitizeResources: false,
}, async () => {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, key, { auth: { persistSession: false } });
  clearConsumers();
  const order: string[] = [];
  registerConsumer("test.concurrent", async (ev) => {
    await new Promise((r) => setTimeout(r, 5));
    order.push(ev.id);
    return { ok: true };
  });
  await wipeQueue(admin);

  const tag = "t-bus:concurrent";
  const early = baseEvent({
    idempotency_key: "c-a",
    ordering_tag: tag,
    occurred_at: new Date("2018-01-01T00:00:00.000Z").toISOString(),
  });
  const late = baseEvent({
    idempotency_key: "c-b",
    ordering_tag: tag,
    occurred_at: new Date("2018-02-01T00:00:00.000Z").toISOString(),
  });
  const { data: e1 } = await admin.from("system_event").insert(early).select()
    .single();
  const { data: e2 } = await admin.from("system_event").insert(late).select()
    .single();
  assertExists(e1);
  assertExists(e2);
  const e1i = e1.id;
  const e2i = e2.id;

  await Promise.all([
    runProcessEventWorker(admin),
    runProcessEventWorker(admin),
  ]);

  for (let i = 0; i < 50; i++) {
    if (order.length >= 2) break;
    await new Promise((r) => setTimeout(r, 50));
  }

  const i1 = order.indexOf(e1i);
  const i2 = order.indexOf(e2i);
  assertEquals(i1 >= 0 && i2 >= 0 && i1 < i2, true);
});
