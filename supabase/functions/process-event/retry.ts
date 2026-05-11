/**
 * Exponential backoff with symmetric jitter (phase 1.5 contract).
 *
 * After the k-th failed attempt (k ≥ 1), the worker schedules the next try at:
 *
 *   delayMs = min(capMs, baseMs * 2^(k - 1)) * (1 + U)
 *   where U ~ Uniform[-jitterFraction, +jitterFraction]
 *
 * `nowMs` is included for stable unit tests.
 */
export function computeNextAttemptAfterFailureMs(args: {
  failureAttempt: number;
  baseMs?: number;
  capMs?: number;
  jitterFraction?: number;
  nowMs: number;
  random: () => number;
}): number {
  const baseMs = args.baseMs ?? 200;
  const capMs = args.capMs ?? 5 * 60 * 1000;
  const jitterFraction = args.jitterFraction ?? 0.25;
  const k = Math.max(1, Math.floor(args.failureAttempt));
  const raw = Math.min(capMs, baseMs * Math.pow(2, k - 1));
  const u = (args.random() * 2 - 1) * jitterFraction;
  const delay = Math.max(0, Math.floor(raw * (1 + u)));
  return args.nowMs + delay;
}
