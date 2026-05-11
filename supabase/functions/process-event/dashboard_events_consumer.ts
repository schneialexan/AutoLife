import type { ConsumerHandler } from "./types.ts";

/**
 * Phase 1.8 dashboard smoke consumer.
 *
 * Drift is hydrated from `system_event` via incremental sync (phase 1.6); this
 * handler only has to complete so `event_delivery` reaches `succeeded`.
 *
 * When `payload.smoke_flaky === true`, the first delivery attempt throws so CI
 * can assert retry → success using the real worker (see `phase1_smoke_test`).
 */
export const dashboardEventsConsumer: ConsumerHandler = async ({
  client,
  event,
}) => {
  const flaky = event.payload.smoke_flaky === true;
  if (flaky) {
    const { data, error } = await client
      .from("event_delivery")
      .select("attempt")
      .eq("event_id", event.id)
      .eq("consumer", "dashboard")
      .maybeSingle();
    if (error) throw error;
    const attempt = typeof data?.attempt === "number" ? data.attempt : 0;
    if (attempt === 0) {
      throw new Error("dashboard_smoke_flaky_first_attempt");
    }
  }
};
