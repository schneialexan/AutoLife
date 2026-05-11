import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import type { SystemEventRow } from "./types.ts";

export type ConsumerContext = {
  client: SupabaseClient;
  event: SystemEventRow;
};

export type ConsumerHandler = (ctx: ConsumerContext) => Promise<void>;

export type ConsumerRegistry = Map<string, ConsumerHandler>;

/** Phase 3 modules register handlers here (empty registry is valid). */
export const consumerRegistry = new Map<string, ConsumerHandler>();
