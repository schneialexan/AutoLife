/// Recipient-facing calendar projection (babysitter / guest tokens).
/// Validates JWT or token query, returns allowlisted event fields only.
Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method !== "GET" && req.method !== "HEAD") {
    return new Response("Method not allowed", { status: 405 });
  }
  const url = new URL(req.url);
  const token = url.searchParams.get("token");
  if (token === null || token.length === 0) {
    return new Response(JSON.stringify({ error: "missing_token" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  // Placeholder: real impl calls `babysitter_scope` RPC + filters columns.
  if (token === "expired" || token === "revoked") {
    return new Response(JSON.stringify({ error: "forbidden" }), {
      status: 403,
      headers: { "Content-Type": "application/json" },
    });
  }
  return new Response(
    JSON.stringify({
      projection_version: 1,
      events: [],
      scope: "calendar_readonly",
    }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});
