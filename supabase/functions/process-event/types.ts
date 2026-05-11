/// Mirrors `packages/autolife-core` `SystemEvent` JSON shape (snake_case keys).

import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

export type JsonObject = Record<string, unknown>;

export interface SystemEventRow {
  id: string;
  tenant_id: string;
  actor_id: string;
  module: string;
  type: string;
  payload: JsonObject;
  idempotency_key: string;
  occurred_at: string;
  ordering_tag: string;
  schema_version: number;
}

export type ConsumerContext = {
  client: SupabaseClient;
  event: SystemEventRow;
};

export type ConsumerHandler = (ctx: ConsumerContext) => Promise<void>;

export type ConsumerRegistry = Map<string, ConsumerHandler>;

export type EventDeliveryStatus =
  | "pending"
  | "succeeded"
  | "failed"
  | "dead_letter";

export interface EventDeliveryRow {
  id: string;
  event_id: string;
  consumer: string;
  attempt: number;
  status: EventDeliveryStatus;
  last_error: string | null;
  next_attempt_at: string | null;
}
