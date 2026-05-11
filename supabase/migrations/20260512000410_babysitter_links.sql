-- Phase 2.5: time-limited babysitter read links + scope helper for RLS / clients.

create table public.babysitter_links (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  token_hash text not null,
  label text not null default '',
  wifi_credentials boolean not null default false,
  emergency_contacts boolean not null default false,
  allergies boolean not null default false,
  locations boolean not null default false,
  created_by uuid not null references public.profile (id) on delete cascade,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now ()
);

comment on table public.babysitter_links is 'Tokenized (hashed), owner-created, read-scope contract for temporary guests; see docs/privacy-tiers.md.';

create unique index babysitter_links_token_hash_key on public.babysitter_links (token_hash);

create index babysitter_links_family_id_idx on public.babysitter_links (family_id);

create table public.babysitter_link_access_logs (
  id uuid primary key default gen_random_uuid (),
  babysitter_link_id uuid not null references public.babysitter_links (id) on delete cascade,
  accessed_at timestamptz not null default now (),
  client_meta jsonb not null default '{}'::jsonb
);

comment on table public.babysitter_link_access_logs is 'Successful token introspections; insert via SECURITY DEFINER helper only.';

create index babysitter_link_access_logs_link_idx on public.babysitter_link_access_logs (babysitter_link_id);

alter table public.babysitter_links enable row level security;

alter table public.babysitter_link_access_logs enable row level security;

-- No direct access to logs for authenticated clients.
create policy babysitter_link_access_logs_deny_all on public.babysitter_link_access_logs for all to authenticated using (false)
with
  check (false);

create policy babysitter_links_select_owner on public.babysitter_links for
select to authenticated using (public.is_owner_of (family_id));

create policy babysitter_links_insert_owner on public.babysitter_links for insert to authenticated
with
  check (
    created_by = (select auth.uid ())
    and public.is_owner_of (family_id)
  );

create policy babysitter_links_update_owner on public.babysitter_links for
update to authenticated using (public.is_owner_of (family_id))
with
  check (public.is_owner_of (family_id));

grant select, insert, update on table public.babysitter_links to authenticated;

-- ---------------------------------------------------------------------------
-- Introspection: map raw token → JSON scope (anon + authenticated).
-- Two-arg form has no defaults so PostgREST can disambiguate the 1-arg overload.
-- ---------------------------------------------------------------------------
create or replace function public.babysitter_scope (p_token text, p_client_meta jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, extensions
as $$
declare
  v_hash text;
  rec public.babysitter_links%rowtype;
  v_resources jsonb;
begin
  if p_token is null or length(trim(p_token)) = 0 then
    return jsonb_build_object('status', 'invalid');
  end if;

  v_hash := encode(digest(p_token, 'sha256'), 'hex');

  select
    * into strict rec
  from
    public.babysitter_links bl
  where
    bl.token_hash = v_hash;

  if rec.revoked_at is not null then
    return jsonb_build_object('status', 'revoked');
  end if;

  if rec.expires_at <= now() then
    return jsonb_build_object('status', 'expired');
  end if;

  select
    coalesce(jsonb_agg(to_jsonb(u.r) order by u.ord), '[]'::jsonb) into v_resources
  from (
    select
      1 as ord,
      'wifi_credentials'::text as r
    where
      rec.wifi_credentials
    union all
    select
      2,
      'emergency_contacts'
    where
      rec.emergency_contacts
    union all
    select
      3,
      'allergies'
    where
      rec.allergies
    union all
    select
      4,
      'locations'
    where
      rec.locations
  ) u;

  insert into public.babysitter_link_access_logs (babysitter_link_id, client_meta)
    values (rec.id, coalesce(p_client_meta, '{}'::jsonb));

  return jsonb_build_object(
    'status',
    'ok',
    'family_id',
    rec.family_id,
    'link_id',
    rec.id,
    'resources',
    v_resources
  );
exception
  when no_data_found then
    return jsonb_build_object('status', 'invalid');
  when too_many_rows then
    return jsonb_build_object('status', 'invalid');
end;
$$;

comment on function public.babysitter_scope (text, jsonb) is 'Resolve babysitter link token to family + enabled resource keys; logs successful lookups.';

-- PostgREST-friendly single-argument overload.
create or replace function public.babysitter_scope (p_token text)
returns jsonb
language sql
volatile
security definer
set search_path = public
as $$
  select public.babysitter_scope (p_token, '{}'::jsonb);
$$;

comment on function public.babysitter_scope (text) is 'Convenience overload defaulting audit meta to empty object.';

grant execute on function public.babysitter_scope (text, jsonb) to anon;

grant execute on function public.babysitter_scope (text, jsonb) to authenticated;

grant execute on function public.babysitter_scope (text) to anon;

grant execute on function public.babysitter_scope (text) to authenticated;

-- ---------------------------------------------------------------------------
-- Tier registry rows for new tables (Phase 2.5)
-- ---------------------------------------------------------------------------
insert into public.sensitivity_assignments (table_schema, table_name, column_name, tier)
values
  ('public', 'babysitter_links', 'id', 'public_family'),
  ('public', 'babysitter_links', 'family_id', 'public_family'),
  ('public', 'babysitter_links', 'token_hash', 'public_family'),
  ('public', 'babysitter_links', 'label', 'public_family'),
  ('public', 'babysitter_links', 'wifi_credentials', 'public_family'),
  ('public', 'babysitter_links', 'emergency_contacts', 'public_family'),
  ('public', 'babysitter_links', 'allergies', 'public_family'),
  ('public', 'babysitter_links', 'locations', 'public_family'),
  ('public', 'babysitter_links', 'created_by', 'public_family'),
  ('public', 'babysitter_links', 'expires_at', 'public_family'),
  ('public', 'babysitter_links', 'revoked_at', 'public_family'),
  ('public', 'babysitter_links', 'created_at', 'public_family'),
  ('public', 'babysitter_links', 'updated_at', 'public_family'),
  ('public', 'babysitter_link_access_logs', 'id', 'public_family'),
  ('public', 'babysitter_link_access_logs', 'babysitter_link_id', 'public_family'),
  ('public', 'babysitter_link_access_logs', 'accessed_at', 'public_family'),
  ('public', 'babysitter_link_access_logs', 'client_meta', 'public_family')
on conflict (table_schema, table_name, column_name) do update set
  tier = excluded.tier,
  updated_at = now();
