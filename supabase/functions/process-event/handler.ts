import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

import { releaseOrderingTagLease, tryAcquireOrderingTagLease } from "./locks.ts";
import type { ConsumerRegistry } from "./registry.ts";
import { consumerRegistry } from "./registry.ts";
import { computeNextAttemptAfterFailureMs } from "./retry.ts";
import type {
  EventDeliveryRow,
  EventDeliveryStatus,
  JsonObject,
  SystemEventRow,
} from "./types.ts";

type ProcessBody =
  | { event_id?: string; scan_stalled?: boolean };

function utcIsoNow(): string {
  return new Date().toISOString();
}

async function broadcastDeadLetter(
  url: string,
  serviceRoleKey: string,
  payload: JsonObject,
): Promise<void> {
  try {
    const realtimeClient = createClient(url, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
    });

    const channel = realtimeClient.channel("dead_letter_event", {
      config: {
        broadcast: { self: true },
      },
    });

    await new Promise<void>((resolve, reject) => {
      channel.subscribe((status, err) => {
        if (status === "SUBSCRIBED") resolve();
        if (status === "CHANNEL_ERROR") {
          reject(err ?? new Error("realtime subscribe failed"));
        }
        if (status === "TIMED_OUT") reject(new Error("realtime subscribe timed out"));
      });
    });

    await channel.send({
      type: "broadcast",
      event: "dead_letter_delivery",
      payload,
    });

    await realtimeClient.removeChannel(channel);
  } catch (_err) {
    // Persistence to dead_letter is authoritative; realtime is best-effort.
    console.warn("dead_letter broadcast skipped");
  }
}

async function fetchEvent(
  admin: SupabaseClient,
  eventId: string,
): Promise<SystemEventRow | null> {
  const { data, error } = await admin.from("system_event").select("*").eq(
    "id",
    eventId,
  ).maybeSingle<SystemEventRow>();
  if (error) throw error;
  return data;
}

async function fetchDeliveries(
  admin: SupabaseClient,
  eventId: string,
): Promise<EventDeliveryRow[]> {
  const { data, error } = await admin.from("event_delivery").select("*").eq(
    "event_id",
    eventId,
  );
  if (error) throw error;
  return data ?? [];
}

function isRunnableDelivery(row: EventDeliveryRow, nowMs: number): boolean {
  if (row.status === "succeeded" || row.status === "dead_letter") return false;

  const next = row.next_attempt_at !== null &&
      row.next_attempt_at !== undefined
    ? Date.parse(row.next_attempt_at)
    : null;
  if (next !== null && !Number.isFinite(next)) return false;

  const due = next === null || Number.isNaN(next) ? true : next <= nowMs;
  return due;
}

function terminalStatus(st: EventDeliveryStatus): boolean {
  return st === "succeeded" || st === "dead_letter";
}

async function upsertDeliveriesForConsumers(
  admin: SupabaseClient,
  eventId: string,
  registry: ConsumerRegistry,
): Promise<void> {
  for (const consumerId of registry.keys()) {
    const { error } = await admin.from("event_delivery").upsert(
      {
        event_id: eventId,
        consumer: consumerId,
        attempt: 0,
        status: "pending",
      },
      { onConflict: "event_id,consumer", ignoreDuplicates: true },
    );
    if (error) throw error;
  }
}

async function fetchNextRunnableEventForTag(
  admin: SupabaseClient,
  registry: ConsumerRegistry,
  tag: string,
  nowMs: number,
): Promise<SystemEventRow | null> {
  if (registry.size === 0) return null;

  const { data: events, error } = await admin.from("system_event").select("*")
    .eq("ordering_tag", tag)
    .order("occurred_at", { ascending: true })
    .order("id", { ascending: true });
  if (error) throw error;

  for (const ev of events ?? []) {
    let deliveries = await fetchDeliveries(admin, ev.id);
    if (deliveries.length === 0) {
      await upsertDeliveriesForConsumers(admin, ev.id, registry);
      deliveries = await fetchDeliveries(admin, ev.id);
    }

    const allTerminal = deliveries.length > 0 &&
      deliveries.every((d) => terminalStatus(d.status));

    if (allTerminal) {
      continue;
    }

    const anyDue = deliveries.some((d) => isRunnableDelivery(d, nowMs));
    if (anyDue) {
      return ev;
    }

    return null;
  }

  return null;
}

async function processDeliveryAttempt(args: {
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceRoleKey: string;
  registry: ConsumerRegistry;
  event: SystemEventRow;
  delivery: EventDeliveryRow;
  nowMs: number;
  random: () => number;
}): Promise<void> {
  const handler = args.registry.get(args.delivery.consumer);
  if (!handler) {
    throw new Error(`missing_consumer_handler:${args.delivery.consumer}`);
  }

  try {
    await handler({ client: args.admin, event: args.event });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    const nextAttemptNum = args.delivery.attempt + 1;

    if (nextAttemptNum >= 5) {
      const { error } = await args.admin.from("event_delivery").update({
        attempt: nextAttemptNum,
        status: "dead_letter",
        last_error: message,
        next_attempt_at: null,
      }).eq("id", args.delivery.id);
      if (error) throw error;

      try {
        await broadcastDeadLetter(args.supabaseUrl, args.serviceRoleKey, {
          delivery_id: args.delivery.id,
          event_id: args.event.id,
          consumer: args.delivery.consumer,
          tenant_id: args.event.tenant_id,
        });
      } catch (_err) {}

      return;
    }

    const nextMs = computeNextAttemptAfterFailureMs({
      failureAttempt: nextAttemptNum,
      nowMs: args.nowMs,
      random: args.random,
    });

    const { error } = await args.admin.from("event_delivery").update({
      attempt: nextAttemptNum,
      status: "pending",
      last_error: message,
      next_attempt_at: new Date(nextMs).toISOString(),
    }).eq("id", args.delivery.id);
    if (error) throw error;
    return;
  }

  const nextAttemptNum = args.delivery.attempt + 1;
  const { error } = await args.admin.from("event_delivery").update({
    attempt: nextAttemptNum,
    status: "succeeded",
    last_error: null,
    next_attempt_at: null,
  }).eq("id", args.delivery.id);
  if (error) throw error;
}

async function runDueDeliveriesForEvent(args: {
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceRoleKey: string;
  registry: ConsumerRegistry;
  event: SystemEventRow;
  nowMs: number;
  random: () => number;
}): Promise<void> {
  const deliveries = await fetchDeliveries(args.admin, args.event.id);
  const pending = deliveries.filter((d) => isRunnableDelivery(d, args.nowMs));

  await Promise.all(pending.map((d) =>
    processDeliveryAttempt({
      admin: args.admin,
      supabaseUrl: args.supabaseUrl,
      serviceRoleKey: args.serviceRoleKey,
      registry: args.registry,
      event: args.event,
      delivery: d,
      nowMs: args.nowMs,
      random: args.random,
    })
  ));
}

async function drainOrderingTagQueue(args: {
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceRoleKey: string;
  registry: ConsumerRegistry;
  tag: string;
  lease: string;
  random: () => number;
}): Promise<void> {
  try {
    while (true) {
      const nowMs = Date.now();
      const next = await fetchNextRunnableEventForTag(
        args.admin,
        args.registry,
        args.tag,
        nowMs,
      );
      if (!next) return;

      await upsertDeliveriesForConsumers(args.admin, next.id, args.registry);

      await runDueDeliveriesForEvent({
        admin: args.admin,
        supabaseUrl: args.supabaseUrl,
        serviceRoleKey: args.serviceRoleKey,
        registry: args.registry,
        event: next,
        nowMs,
        random: args.random,
      });
    }
  } finally {
    await releaseOrderingTagLease(args.admin, args.tag, args.lease);
  }
}

async function dispatchFromEventHint(args: {
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceRoleKey: string;
  registry: ConsumerRegistry;
  eventId: string;
  random: () => number;
}): Promise<Response> {
  const ev = await fetchEvent(args.admin, args.eventId);
  if (!ev) {
    return jsonResponse({ ok: false, code: "event_not_found" }, 404);
  }

  const lease = crypto.randomUUID();
  const acquired = await tryAcquireOrderingTagLease(
    args.admin,
    ev.ordering_tag,
    lease,
  );
  if (!acquired) {
    return jsonResponse({ ok: true, deferred: true }, 202);
  }

  await drainOrderingTagQueue({
    admin: args.admin,
    supabaseUrl: args.supabaseUrl,
    serviceRoleKey: args.serviceRoleKey,
    registry: args.registry,
    tag: ev.ordering_tag,
    lease,
    random: args.random,
  });

  return jsonResponse({ ok: true, drained: true }, 200);
}

async function dispatchStalledScan(args: {
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceRoleKey: string;
  registry: ConsumerRegistry;
  random: () => number;
}): Promise<Response> {
  const nowIso = utcIsoNow();

  const { data: rows, error } = await args.admin.from("event_delivery").select(
    "event_id,status,next_attempt_at",
  ).in(
    "status",
    ["pending"],
  ).or(`next_attempt_at.is.null,next_attempt_at.lte.${nowIso}`);
  if (error) throw error;

  const eventIds = new Set<string>();
  for (const r of rows ?? []) {
    if (!r.event_id) continue;
    eventIds.add(r.event_id as string);
  }

  const tags = new Set<string>();
  for (const id of eventIds) {
    const ev = await fetchEvent(args.admin, id);
    if (!ev) continue;

    tags.add(ev.ordering_tag);
  }

  for (const tag of tags) {
    const lease = crypto.randomUUID();
    const acquired = await tryAcquireOrderingTagLease(
      args.admin,
      tag,
      lease,
    );
    if (!acquired) continue;

    await drainOrderingTagQueue({
      admin: args.admin,
      supabaseUrl: args.supabaseUrl,
      serviceRoleKey: args.serviceRoleKey,
      registry: args.registry,
      tag,
      lease,
      random: args.random,
    });
  }

  return jsonResponse({
    ok: true,
    scan: true,
    tags_touched: Array.from(tags),
    now_iso: nowIso,
  }, 200);
}

function jsonResponse(body: JsonObject, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export type ProcessEventDeps = {
  registry?: ConsumerRegistry;
  random?: () => number;
};

export async function handleProcessEvent(
  req: Request,
  deps?: ProcessEventDeps,
): Promise<Response> {
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse({ ok: false, code: "missing_supabase_env" }, 500);
  }

  const registry = deps?.registry ?? consumerRegistry;
  const randomFn = deps?.random ?? Math.random;

  let body: ProcessBody = {};
  try {
    body = await req.json() as ProcessBody;
  } catch {
    body = {};
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });

  try {
    if (body.scan_stalled === true) {
      return await dispatchStalledScan({
        admin,
        supabaseUrl,
        serviceRoleKey,
        registry,
        random: randomFn,
      });
    }

    const eventId = body.event_id;
    if (!eventId) return jsonResponse({ ok: false, code: "missing_event_id" }, 400);

    return await dispatchFromEventHint({
      admin,
      supabaseUrl,
      serviceRoleKey,
      registry,
      eventId,
      random: randomFn,
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return jsonResponse({ ok: false, code: "internal_error", message }, 500);
  }
}
