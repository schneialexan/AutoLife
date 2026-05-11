import { assertEquals } from "jsr:@std/assert@1";
import { backoffMsAfterFailure } from "../retry.ts";

Deno.test("backoff k=1 stays within base + 20% jitter", () => {
  for (let i = 0; i < 30; i++) {
    const ms = backoffMsAfterFailure(1);
    assertEquals(ms >= 200 && ms <= 200 + 0.2 * 200 + 1, true);
  }
});

Deno.test("backoff caps at 60s", () => {
  for (let k = 1; k <= 5; k++) {
    for (let i = 0; i < 10; i++) {
      const ms = backoffMsAfterFailure(k);
      assertEquals(ms <= 60_000, true);
    }
  }
});
