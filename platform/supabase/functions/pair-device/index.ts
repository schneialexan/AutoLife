// pair-device — service-role Edge Function for optional device linking.
//
// Two actions:
//   { action: "start" }            (caller must be authenticated)
//     -> creates a high-entropy, short-TTL, single-use code (stored HASHED)
//     -> returns { code, expires_at } (plaintext code shown on trusted device)
//
//   { action: "complete", code }   (fresh device, no session yet)
//     -> validates the code (single-use, attempt-limited, unexpired)
//     -> mints a one-time magic-link OTP for the owner's email
//     -> returns { email, token } which the new device exchanges via verifyOtp
//
// The service-role key never leaves this function; the client never mints
// sessions directly.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const CODE_TTL_MINUTES = 10;
const MAX_ATTEMPTS = 5;
const CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"; // no ambiguous chars
const CODE_LENGTH = 8;

const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function generateCode(): string {
  const bytes = new Uint8Array(CODE_LENGTH);
  crypto.getRandomValues(bytes);
  let out = "";
  for (const b of bytes) {
    out += CODE_ALPHABET[b % CODE_ALPHABET.length];
  }
  return out;
}

async function hashCode(code: string): Promise<string> {
  const data = new TextEncoder().encode(code.trim().toUpperCase());
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function handleStart(req: Request): Promise<Response> {
  const authHeader = req.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace(/^Bearer\s+/i, "");
  if (!jwt) {
    return json({ error: "missing_token" }, 401);
  }
  const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
  if (userErr || !userData.user) {
    return json({ error: "invalid_token" }, 401);
  }
  const userId = userData.user.id;

  const code = generateCode();
  const codeHash = await hashCode(code);
  const expiresAt = new Date(
    Date.now() + CODE_TTL_MINUTES * 60 * 1000,
  ).toISOString();

  const { error: insertErr } = await admin
    .from("device_pairing_codes")
    .insert({ user_id: userId, code_hash: codeHash, expires_at: expiresAt });
  if (insertErr) {
    return json({ error: "could_not_create_code" }, 500);
  }
  return json({ code, expires_at: expiresAt });
}

async function handleComplete(code: string): Promise<Response> {
  if (!code || code.trim().length === 0) {
    return json({ error: "empty_code" }, 400);
  }
  const codeHash = await hashCode(code);
  const nowIso = new Date().toISOString();

  const { data: row } = await admin
    .from("device_pairing_codes")
    .select("id, user_id, attempts, expires_at, used_at")
    .eq("code_hash", codeHash)
    .is("used_at", null)
    .gt("expires_at", nowIso)
    .maybeSingle();

  if (!row) {
    return json({ error: "pairing_invalid" }, 400);
  }
  if (row.attempts >= MAX_ATTEMPTS) {
    await admin
      .from("device_pairing_codes")
      .update({ used_at: nowIso })
      .eq("id", row.id);
    return json({ error: "pairing_locked" }, 429);
  }

  // Single-use: mark consumed before minting the token.
  await admin
    .from("device_pairing_codes")
    .update({ used_at: nowIso, attempts: row.attempts + 1 })
    .eq("id", row.id);

  const { data: userData, error: userErr } = await admin.auth.admin.getUserById(
    row.user_id,
  );
  if (userErr || !userData.user?.email) {
    return json({ error: "user_unavailable" }, 500);
  }
  const email = userData.user.email;

  const { data: linkData, error: linkErr } = await admin.auth.admin.generateLink(
    { type: "magiclink", email },
  );
  if (linkErr || !linkData.properties?.email_otp) {
    return json({ error: "token_mint_failed" }, 500);
  }

  return json({ email, token: linkData.properties.email_otp });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }
  let body: { action?: string; code?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_body" }, 400);
  }

  switch (body.action) {
    case "start":
      return await handleStart(req);
    case "complete":
      return await handleComplete(body.code ?? "");
    default:
      return json({ error: "unknown_action" }, 400);
  }
});
