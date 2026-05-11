const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function hex(bytes: Uint8Array): string {
  return [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function sha256HexUtf8(text: string): Promise<string> {
  const data = new TextEncoder().encode(text);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return hex(new Uint8Array(digest));
}

function randomToken(): string {
  const buf = new Uint8Array(32);
  crypto.getRandomValues(buf);
  return hex(buf);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("method not allowed", { status: 405, headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  if (!supabaseUrl || !anonKey) {
    return new Response("edge function missing supabase env", {
      status: 500,
      headers: corsHeaders,
    });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  let body: {
    family_id?: string;
    email?: string;
    invited_role?: string;
  };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "invalid_json" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const familyId = body.family_id?.trim();
  const emailRaw = body.email?.trim().toLowerCase();
  const invitedRole = (body.invited_role ?? "partner").trim().toLowerCase();
  if (!familyId || !emailRaw || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailRaw)) {
    return new Response(JSON.stringify({ error: "invalid_body" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const { createClient } = await import("npm:@supabase/supabase-js@2");
  const supabase = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData.user) {
    return new Response(JSON.stringify({ error: "unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const rawToken = randomToken();
  const tokenHash = await sha256HexUtf8(rawToken.trim());
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

  const row = {
    family_id: familyId,
    email: emailRaw,
    invited_role: invitedRole,
    invited_by: userData.user.id,
    token_hash: tokenHash,
    expires_at: expiresAt,
  };

  const { data: inserted, error: insErr } = await supabase
    .from("family_invitations")
    .insert(row)
    .select(
      "id, family_id, email, invited_role, invited_by, expires_at, accepted_at, revoked_at, created_at, updated_at",
    )
    .single();

  if (insErr) {
    console.error("send-invitation insert failed", insErr);
    return new Response(JSON.stringify({ error: insErr.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const deepBase = Deno.env.get("AUTOLIFE_INVITE_DEEP_LINK_BASE") ?? "autolife:";
  const acceptPath = Deno.env.get("AUTOLIFE_INVITE_PATH") ?? "//invite";
  const acceptUrl = `${deepBase}${acceptPath}?token=${encodeURIComponent(rawToken)}`;
  console.log(
    JSON.stringify({
      event: "family_invitation_sent",
      to: emailRaw,
      family_id: familyId,
      acceptUrl,
    }),
  );

  const resBody = { invitation: inserted, accept_url: acceptUrl };
  return new Response(JSON.stringify(resBody), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
