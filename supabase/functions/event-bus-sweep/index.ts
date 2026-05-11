import { createClient } from "npm:@supabase/supabase-js@2";
import { runProcessEventWorker } from "../process-event/worker.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "method_not_allowed" }),
      {
        status: 405,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
  const url = Deno.env.get("SUPABASE_URL") ?? "";
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (!url || !key) {
    return new Response(
      JSON.stringify({ error: "missing_env" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
  const admin = createClient(url, key, { auth: { persistSession: false } });
  return await runProcessEventWorker(admin);
});
