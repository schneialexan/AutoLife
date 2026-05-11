-- Phase 1.7: Vault-backed connector credentials + lifecycle audit trail.

create extension if not exists supabase_vault;

create type public.connector_direction as enum (
  'one_way_in',
  'one_way_out',
  'two_way'
);

comment on type public.connector_direction is 'Sync direction per connector instance (Idea-Refined Part 5.6).';

create table public.connector_credential (
  tenant_id text not null,
  connector_id text not null,
  vault_secret_id uuid not null,
  direction public.connector_direction not null default 'two_way',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (tenant_id, connector_id)
);

comment on table public.connector_credential is 'One credential bundle per tenant+connector; secrets live in Vault via vault_secret_id only.';

comment on column public.connector_credential.metadata is 'Non-sensitive labels only — never token material.';

create index connector_credential_tenant_idx on public.connector_credential (tenant_id);

create table public.connector_event (
  id uuid primary key default gen_random_uuid (),
  tenant_id text not null,
  connector_id text not null,
  kind text not null,
  outcome text not null,
  error_detail text,
  detail jsonb not null default '{}'::jsonb,
  client_ip text,
  user_agent text,
  occurred_at timestamptz not null default now(),
  constraint connector_event_outcome_chk check (outcome in ('success', 'failure'))
);

comment on table public.connector_event is 'Audit trail for connector lifecycle, OAuth, and errors.';

create index connector_event_tenant_occurred_idx on public.connector_event (
  tenant_id,
  occurred_at desc
);

create index connector_event_connector_idx on public.connector_event (connector_id, occurred_at desc);

alter table public.connector_credential enable row level security;

alter table public.connector_event enable row level security;

-- Stores JSON credential bundles encrypted by Vault; callable only from trusted server contexts (service role).
create or replace function public.integration_store_connector_secret (
  p_tenant_id text,
  p_connector_id text,
  p_secret_json jsonb,
  p_direction public.connector_direction default 'two_way'
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_name text := 'connector:' || p_tenant_id || ':' || p_connector_id;
  v_existing uuid;
  v_new uuid;
begin
  if p_tenant_id is null or length(trim(p_tenant_id)) = 0 then
    raise exception 'tenant_id required';
  end if;
  if p_connector_id is null or length(trim(p_connector_id)) = 0 then
    raise exception 'connector_id required';
  end if;

  select cc.vault_secret_id
    into v_existing
  from public.connector_credential cc
  where cc.tenant_id = p_tenant_id
    and cc.connector_id = p_connector_id;

  if v_existing is not null then
    perform vault.update_secret(
      v_existing,
      p_secret_json::text,
      null,
      null
    );
    update public.connector_credential
       set direction = p_direction,
           updated_at = now()
     where tenant_id = p_tenant_id
       and connector_id = p_connector_id;
    return v_existing;
  end if;

  v_new := vault.create_secret(
    p_secret_json::text,
    v_name,
    'AutoLife connector OAuth bundle'
  );

  insert into public.connector_credential (
    tenant_id,
    connector_id,
    vault_secret_id,
    direction
  )
  values (
    p_tenant_id,
    p_connector_id,
    v_new,
    p_direction
  );

  return v_new;
end;
$$;

comment on function public.integration_store_connector_secret is 'Upsert connector tokens into Vault; Edge Functions use service role only.';

revoke all on function public.integration_store_connector_secret (text, text, jsonb, public.connector_direction)
from public;

grant execute on function public.integration_store_connector_secret (text, text, jsonb, public.connector_direction)
to service_role;
