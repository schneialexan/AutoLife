import { assertEquals } from "jsr:@std/assert@1";

import { computeNextAttemptAfterFailureMs } from "./retry.ts";

Deno.test("backoff respects exponential growth with jitter=0", () => {
  const base = 10;
  const t0 = 1_000_000;
  const r = computeNextAttemptAfterFailureMs({
    failureAttempt: 1,
    baseMs: base,
    capMs: 1_000_000,
    jitterFraction: 0,
    nowMs: t0,
    random: () => 1,
  });
  const t1 = computeNextAttemptAfterFailureMs({
    failureAttempt: 2,
    baseMs: base,
    capMs: 1_000_000,
    jitterFraction: 0,
    nowMs: t0,
    random: () => 1,
  });
  const t2 = computeNextAttemptAfterFailureMs({
    failureAttempt: 3,
    baseMs: base,
    capMs: 1_000_000,
    jitterFraction: 0,
    nowMs: t0,
    random: () => 1,
  });

  assertEquals(t0 + 10, t1);
  assertEquals(t0 + 20, t2);
});

Deno.test("backoff is capped when exponent would exceed cap", () => {
  const t0 = 0;
  const next = computeNextAttemptAfterFailureMs({
    failureAttempt: 20,
    baseMs: 10,
    capMs: 77,
    jitterFraction: 0,
    nowMs: t0,
    random: () => 1,
  });
  assertEquals(next, 77);
});
