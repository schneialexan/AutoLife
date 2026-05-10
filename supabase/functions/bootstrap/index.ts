import { createClient } from "jsr:@supabase/supabase-js@2";

type Json = Record<string, unknown>;

function jsonResponse(status: number, body: Json) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
}

Deno.serve(async (req) => {
  try {
    const url = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!url || !anonKey || !serviceRoleKey) {
      return jsonResponse(500, {
        ready: false,
        error:
          "Missing SUPABASE_URL / SUPABASE_ANON_KEY / SUPABASE_SERVICE_ROLE_KEY in Edge Function env.",
      });
    }

    const authHeader =
      req.headers.get("Authorization") ?? req.headers.get("authorization") ?? "";

    const authed = createClient(url, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: userData, error: userError } = await authed.auth.getUser();
    if (userError || !userData?.user) {
      return jsonResponse(401, { ready: false, error: "Unauthorized" });
    }

    const user = userData.user;
    const userId = user.id;

    const admin = createClient(url, serviceRoleKey, {
      auth: { persistSession: false },
    });

    // Ensure profile exists (trigger should create it, but this is safe/idempotent).
    const { data: profile, error: profileError } = await admin
      .from("profiles")
      .select("id,family_id,display_name")
      .eq("id", userId)
      .maybeSingle();

    if (profileError) {
      return jsonResponse(500, { ready: false, error: profileError.message });
    }

    if (profile?.family_id) {
      return jsonResponse(200, {
        ready: true,
        profile_id: profile.id,
        family_id: profile.family_id,
        display_name: profile.display_name,
      });
    }

    const displayName =
      (typeof user.user_metadata?.display_name === "string" &&
        user.user_metadata.display_name.trim()) ||
      (user.email ? user.email.split("@")[0] : "") ||
      "User";

    const familyName =
      (typeof user.user_metadata?.family_name === "string" &&
        user.user_metadata.family_name.trim()) ||
      `${displayName}'s Family`;

    // Create a family and upsert the profile to satisfy NOT NULL constraints.
    const { data: familyInsert, error: familyError } = await admin
      .from("families")
      .insert({ name: familyName })
      .select("id")
      .single();

    if (familyError || !familyInsert?.id) {
      return jsonResponse(500, {
        ready: false,
        error: familyError?.message ?? "Failed to create family",
      });
    }

    const familyId = familyInsert.id as string;

    const { error: upsertError } = await admin.from("profiles").upsert(
      {
        id: userId,
        family_id: familyId,
        display_name: displayName,
      },
      { onConflict: "id" },
    );

    if (upsertError) {
      return jsonResponse(500, { ready: false, error: upsertError.message });
    }

    return jsonResponse(200, {
      ready: true,
      profile_id: userId,
      family_id: familyId,
      display_name: displayName,
    });
  } catch (e) {
    return jsonResponse(500, {
      ready: false,
      error: e instanceof Error ? e.message : String(e),
    });
  }
});
