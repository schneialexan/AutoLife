import { assert, assertEquals, assertExists } from "jsr:@std/assert@1";
import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

import { handleProcessEvent } from "../handler.ts";
import type { ConsumerHandler, ConsumerRegistry } from "../registry.ts";

const hasIntegrationEnv = (): boolean =>
  Boolean(Deno.env.get("SUPABASE_URL")) &&
  Boolean(Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));

function integration(name: string, fn: () => Promise<void>) {
  Deno.test({ name, ignore: !hasIntegrationEnv(), fn });
}

function adminClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  return createClient(url, key, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
}

function postJson(body: Record<string, unknown>): Request {
  return new Request("http://local/", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
}

type SystemEventSeed = {
  tenant_id: string;
  actor_id: string;
  module: string;
  type: string;
  payload: Record<string, unknown>;
  idempotency_key: string;
  ordering_tag: string;
  occurred_at: string;
  schema_version: number;
};

async function insertEvent(
  admin: SupabaseClient,
  overrides?: Partial<SystemEventSeed>,
): Promise<string> {
  const base: SystemEventSeed = {
    tenant_id: overrides?.tenant_id ?? "tenant_it",
    actor_id: overrides?.actor_id ?? "actor_it",
    module: overrides?.module ?? "it_module",
    type: overrides?.type ?? "it.type",
    payload: overrides?.payload ?? { ping: true },
    idempotency_key: overrides?.idempotency_key ?? crypto.randomUUID(),
    ordering_tag: overrides?.ordering_tag ?? `tag:${crypto.randomUUID()}`,
    occurred_at: overrides?.occurred_at ?? new Date().toISOString(),
    schema_version: overrides?.schema_version ?? 1,
  };

  const { data, error } = await admin.from("system_event").insert(base).select(
    "id",
  ).maybeSingle<{ id: string }>();
  if (error) throw error;
  assertExists(data);
  assertExists(data.id);
  return data.id;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

integration("happy-path: delivery succeeds with attempt 1", async () => {
  const registry: ConsumerRegistry = new Map([
    ["it.happy", (async (_ctx) => await Promise.resolve()) as ConsumerHandler],
  ]);

  const admin = adminClient();
  const eventId = await insertEvent(admin);

  const res = await handleProcessEvent(
    postJson({ event_id: eventId }),
    { registry },
  );

  assertEquals(res.status, 200);

  const deliveries = await admin.from("event_delivery").select("*").eq(
    "event_id",
    eventId,
  );

  assertEquals(deliveries.error, null);

  const row = (deliveries.data ?? []).find((d: { consumer: string }) =>
    d.consumer === "it.happy"
  );

  assertExists(row);
  assertEquals(row.status, "succeeded");
  assertEquals(row.attempt, 1);

  await admin.from("system_event").delete().eq("id", eventId);
});

integration("retry path: failures then success ends succeeded with attempt=5", async () => {
  let failsRemaining = 4;
  const scheduledSnapshots: Date[] = [];

  const registry: ConsumerRegistry = new Map([
    ["it.retry", (async (_ctx) => {
      if (failsRemaining > 0) {
        failsRemaining -= 1;
        throw new Error("boom");
      }
      return await Promise.resolve();
    }) as ConsumerHandler],
  ]);

  const admin = adminClient();
  const orderingTag = `tag_retry:${crypto.randomUUID()}`;
  const t1 = new Date(Date.now() - 2_000).toISOString();
  const eventId = await insertEvent(admin, {
    ordering_tag: orderingTag,
    occurred_at: t1,
  });

  await handleProcessEvent(
    postJson({ event_id: eventId }),
    { registry, random: () => 0.5 },
  );

  async function waitFor(predicate: () => Promise<boolean>): Promise<void> {
    const deadline = Date.now() + 90_000;
    while (Date.now() < deadline) {
      if (await predicate()) return;
      await sleep(50);
    }
    throw new Error("timed_out_waiting_for_predicate");
  }

  await waitFor(async () => {
    const { data } = await admin.from("event_delivery").select(
      "status,attempt",
    ).eq("event_id", eventId).eq("consumer", "it.retry").maybeSingle<{
      status: string;
      attempt: number;
    }>();

    return data?.status === "pending" && data.attempt === 1;
  });

  for (let spins = 0; spins < 40; spins++) {
    const { data, error } = await admin.from("event_delivery").select(
      "id,attempt,next_attempt_at,status",
    ).eq("event_id", eventId).maybeSingle<{
      id: string;
      attempt: number;
      next_attempt_at: string | null;
      status: string;
    }>();

    if (error) throw error;
    assertExists(data);

    if (data.status === "succeeded") break;

    assertExists(data.next_attempt_at);
    scheduledSnapshots.push(new Date(data.next_attempt_at));

    await admin.from("event_delivery").update({
      next_attempt_at: new Date(Date.now() - 1).toISOString(),
    }).eq(
      "id",
      data.id,
    );

    await handleProcessEvent(
      postJson({ event_id: eventId }),
      { registry, random: () => 0.5 },
    );
  }

  const done = await admin.from("event_delivery").select("*").eq("event_id", eventId)
    .maybeSingle<{ status: string; attempt: number }>();
  assertEquals(done.error, null);
  assertExists(done.data);
  assertEquals(done.data.status, "succeeded");
  assertEquals(done.data.attempt, 5);

  assert(scheduledSnapshots.length >= 4);
  const gaps = scheduledSnapshots.map((dt, idx) =>
    idx === 0
      ? 0
      : Math.max(
        0,
        dt.getTime() - scheduledSnapshots[idx - 1]!.getTime(),
      )
  ).slice(1);
  for (let j = 1; j < gaps.length; j++) {
    assert(
      gaps[j] >= gaps[j - 1]!,
      "expected exponential backoff to increase spacing between successive scheduled attempts",
    );
  }

  await admin.from("system_event").delete().eq("id", eventId);
});

integration("dead letter after five failures moves delivery to dead_letter", async () => {
  const registry: ConsumerRegistry = new Map([
    ["it.dlq", (async (_ctx) => {
      throw new Error("always_fail");
    }) as ConsumerHandler],
  ]);

  const admin = adminClient();
  const orderingTag = `tag_dlq:${crypto.randomUUID()}`;
  const eventId = await insertEvent(admin, { ordering_tag });

  async function pokeUntil(predicate: () => Promise<boolean>): Promise<void> {
    const deadline = Date.now() + 180_000;
    while (Date.now() < deadline) {
      if (await predicate()) return;

      await handleProcessEvent(
        postJson({ event_id: eventId }),
        { registry, random: () => 0.5 },
      );

      await admin.from("event_delivery").update({
        next_attempt_at: new Date(Date.now() - 5).toISOString(),
      }).eq(
        "event_id",
        eventId,
      );

      await sleep(25);
    }
    throw new Error("timed_out_waiting_for_predicate");
  }

  await pokeUntil(async () => {
    const row = await admin.from("dead_letter_event").select("*").eq(
      "event_id",
      eventId,
    ).maybeSingle();
    assertEquals(row.error, null);
    return row.data !== null;
  });

  const row = await admin.from("dead_letter_event").select("*").eq(
    "event_id",
    eventId,
  ).maybeSingle();
  assertEquals(row.error, null);
  assertExists(row.data);
  assertEquals(row.data.consumer, "it.dlq");
  assertEquals(row.data.attempt, 5);

  await admin.from("system_event").delete().eq("id", eventId);
});

integration(
  "ordering_tag: occurrences run in occurred_at order under concurrency",
  async () => {
    const idsInOrder: string[] = [];

    const registry: ConsumerRegistry = new Map([
      ["it.order", (async ({ event }) => {
        idsInOrder.push(event.id);
        return await Promise.resolve();
      }) as ConsumerHandler],
    ]);

    const admin = adminClient();
    const tag = `tag_order:${crypto.randomUUID()}`;

    const e1 = await insertEvent(admin, {
      ordering_tag: tag,
      occurred_at: new Date(Date.now() - 10_000).toISOString(),
    });

    const e2 = await insertEvent(admin, {
      ordering_tag: tag,
      occurred_at: new Date(Date.now() - 5_000).toISOString(),
    });

    await Promise.all([
      handleProcessEvent(postJson({ event_id: e1 }), { registry }),
      handleProcessEvent(postJson({ event_id: e2 }), { registry }),
      handleProcessEvent(postJson({ event_id: e1 }), { registry }),
      handleProcessEvent(postJson({ event_id: e2 }), { registry }),
    ]);

    await flushTag(admin, registry, tag);

    assertEquals(idsInOrder, [e1, e2]);

    await admin.from("system_event").delete().in("id", [e1, e2]);
  },
);

integration("idempotency: duplicate system_event inserts are rejected by SQL", async () => {
  const admin = adminClient();
  const idemKey = crypto.randomUUID();
  const tenant = `tenant_dupe:${crypto.randomUUID()}`;

  await insertEvent(admin, {
    tenant_id: tenant,
    idempotency_key: idemKey,
    ordering_tag: `tag_dupe:${idemKey}`,
  });

  const second = await admin.from("system_event").insert({
    tenant_id: tenant,
    actor_id: "actor",
    module: "m",
    type: "t",
    payload: { v: 2 },
    idempotency_key: idemKey,
    occurred_at: new Date().toISOString(),
    ordering_tag: `tag_dupe2:${idemKey}`,
    schema_version: 1,
  }).select("id");

  assertExists(second.error);
});

integration("scan_stalled processes tags that have due pending retries", async () => {
  let shouldFailOnce = true;

  const registry: ConsumerRegistry = new Map([
    ["it.scan", (async (_ctx) => {
      if (shouldFailOnce) {
        shouldFailOnce = false;
        throw new Error("first_attempt_only");
      }
      return await Promise.resolve();
    }) as ConsumerHandler],
  ]);

  const admin = adminClient();
  const orderingTag = `tag_scan:${crypto.randomUUID()}`;
  const eventId = await insertEvent(admin, {
    ordering_tag: orderingTag,
  });

  await handleProcessEvent(
    postJson({ event_id: eventId }),
    { registry },
  );

  await admin.from("event_delivery").update({
    next_attempt_at: new Date(Date.now() - 1).toISOString(),
  }).eq(
    "event_id",
    eventId,
  );

  const stalled = await handleProcessEvent(postJson({ scan_stalled: true }), {
    registry,
  });

  assertEquals(stalled.status, 200);

  const done = await admin.from("event_delivery").select("status").eq(
    "event_id",
    eventId,
  ).maybeSingle<{ status: string }>();
  assertEquals(done.error, null);
  assertExists(done.data);
  assertEquals(done.data.status, "succeeded");

  await admin.from("system_event").delete().eq("id", eventId);
});

async function flushTag(
  admin: SupabaseClient,
  registry: ConsumerRegistry,
  tag: string,
): Promise<void> {
  const deadline = Date.now() + 60_000;

  while (Date.now() < deadline) {
    const { data: events } = await admin.from("system_event").select("id").eq(
      "ordering_tag",
      tag,
    );

    const ids = (events ?? []).map((row: { id: string }) => row.id).filter(Boolean);
    let allSucceeded = ids.length !== 0;

    for (const id of ids) {
      await handleProcessEvent(postJson({ event_id: id }), { registry });

      const { data: dels } = await admin.from("event_delivery").select("status").eq(
        "event_id",
        id,
      );

      const ok = (dels ?? []).every((r: { status: string }) => r.status === "succeeded");
      allSucceeded = allSucceeded && ok;
    }

    if (ids.length !== 0 && allSucceeded) return;

    await sleep(25);
  }

  throw new Error("timed_out_waiting_for_flush");
}
