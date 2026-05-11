import { dashboardEventsConsumer } from "./dashboard_events_consumer.ts";
import type { ConsumerHandler, ConsumerRegistry } from "./types.ts";

export type { ConsumerContext, ConsumerHandler, ConsumerRegistry } from "./types.ts";

/** Phase 3 modules register handlers here (empty registry is valid). */
export const consumerRegistry = new Map<string, ConsumerHandler>([
  ["dashboard", dashboardEventsConsumer],
]);
