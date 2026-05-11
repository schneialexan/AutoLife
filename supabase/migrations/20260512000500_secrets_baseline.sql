-- Phase 2.6: reaffirm Vault + document secret slots referenced from docs/security/secret-management.md.
-- Secrets are created at runtime via Supabase tooling; this migration only inventories slot names.

create extension if not exists supabase_vault;

create table if not exists public.phase2_vault_secret_slot (
    slot_name text primary key,
    purpose text not null,
    created_at timestamptz not null default now()
);

comment on table public.phase2_vault_secret_slot is
'Non-secret inventory of Vault logical slots; values must never appear in plaintext columns outside Vault.';

insert into public.phase2_vault_secret_slot (slot_name, purpose)
values
    ('auth.google_client_secret', 'Google OAuth client secret wired into hosted GoTrue.'),
    ('auth.apple_signing_material', 'Apple Sign-In JWT signing bundle (typically .p8 + kid + team id refs).'),
    ('edge.webhook_hmac', 'HMAC signing key verifying inbound webhook requests to Edge Functions.'),
    ('smtp.transactional_secret', 'Optional transactional email provider credential when not using native Supabase mail.')
on conflict (slot_name)
    do nothing;

alter table public.phase2_vault_secret_slot enable row level security;

revoke all on public.phase2_vault_secret_slot
from public;
revoke all on public.phase2_vault_secret_slot
from anon, authenticated;

grant select on public.phase2_vault_secret_slot to service_role;
