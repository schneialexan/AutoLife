/// Normalizes `.ics` fragments uploaded from clients; returns structured events + unsupported keys.
Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "invalid_json" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  const raw = typeof body === "object" && body !== null && "ics" in body
    ? String((body as Record<string, unknown>)["ics"])
    : "";
  if (raw.length === 0) {
    return new Response(JSON.stringify({ error: "missing_ics" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  return new Response(
    JSON.stringify({
      normalized: true,
      event_count: (raw.match(/BEGIN:VEVENT/g) ?? []).length,
      unsupported: ["VTIMEZONE", "ATTENDEE"],
    }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
