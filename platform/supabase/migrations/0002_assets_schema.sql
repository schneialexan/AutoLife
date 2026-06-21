-- AutoAssets module tables (schema `assets`).
-- Mirror the local model JSON in `payload` + sync metadata, plus a
-- DB-assigned `server_updated_at` that pull cursors page on.

create schema if not exists assets;

-- Expose the schema to PostgREST and grant role access (RLS still gates rows).
grant usage on schema assets to anon, authenticated, service_role;
alter default privileges in schema assets
  grant all on tables to anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Shared trigger: stamp server_updated_at with the DB clock on every write.
-- Using now() (not the client clock) makes the pull cursor skew-proof.
-- ---------------------------------------------------------------------------
create or replace function public.set_server_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.server_updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- assets.items
-- ---------------------------------------------------------------------------
create table if not exists assets.items (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  payload jsonb not null,
  schema_version int not null default 1,
  updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id text
);

grant all on table assets.items to anon, authenticated, service_role;

create index if not exists items_pull_idx
  on assets.items (user_id, server_updated_at);
create index if not exists items_active_idx
  on assets.items (user_id) where deleted_at is null;

drop trigger if exists items_server_updated_at on assets.items;
create trigger items_server_updated_at
  before insert or update on assets.items
  for each row execute function public.set_server_updated_at();

alter table assets.items enable row level security;

create policy "items_select_own"
  on assets.items for select using (user_id = auth.uid());
create policy "items_insert_own"
  on assets.items for insert with check (user_id = auth.uid());
create policy "items_update_own"
  on assets.items for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "items_delete_own"
  on assets.items for delete using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- assets.category_types (same shape)
-- ---------------------------------------------------------------------------
create table if not exists assets.category_types (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  payload jsonb not null,
  schema_version int not null default 1,
  updated_at timestamptz not null,
  server_updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id text
);

grant all on table assets.category_types to anon, authenticated, service_role;

create index if not exists category_types_pull_idx
  on assets.category_types (user_id, server_updated_at);
create index if not exists category_types_active_idx
  on assets.category_types (user_id) where deleted_at is null;

drop trigger if exists category_types_server_updated_at on assets.category_types;
create trigger category_types_server_updated_at
  before insert or update on assets.category_types
  for each row execute function public.set_server_updated_at();

alter table assets.category_types enable row level security;

create policy "category_types_select_own"
  on assets.category_types for select using (user_id = auth.uid());
create policy "category_types_insert_own"
  on assets.category_types for insert with check (user_id = auth.uid());
create policy "category_types_update_own"
  on assets.category_types for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "category_types_delete_own"
  on assets.category_types for delete using (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- assets.sync_state (optional diagnostics; primary cursor stays on device)
-- ---------------------------------------------------------------------------
create table if not exists assets.sync_state (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  last_full_sync_at timestamptz
);

grant all on table assets.sync_state to anon, authenticated, service_role;

alter table assets.sync_state enable row level security;

create policy "sync_state_select_own"
  on assets.sync_state for select using (user_id = auth.uid());
create policy "sync_state_upsert_own"
  on assets.sync_state for insert with check (user_id = auth.uid());
create policy "sync_state_update_own"
  on assets.sync_state for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());
