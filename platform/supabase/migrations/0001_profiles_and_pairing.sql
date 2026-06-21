-- AutoLife platform — shared identity tables.
-- Personal-tenancy v1: every row belongs to exactly one auth user.

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles for select
  using (id = auth.uid());

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (id = auth.uid());

create policy "profiles_update_own"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

-- Auto-create a profile row when a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- device_pairing_codes
-- Redemption happens ONLY via the service-role `pair-device` Edge Function.
-- Clients may never SELECT here (prevents code enumeration); they can create
-- their own pending codes.
-- ---------------------------------------------------------------------------
create table if not exists public.device_pairing_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  code_hash text not null,
  attempts int not null default 0,
  expires_at timestamptz not null,
  used_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists device_pairing_codes_user_idx
  on public.device_pairing_codes (user_id);

alter table public.device_pairing_codes enable row level security;

-- Owners may create pairing codes for themselves. No select/update/delete
-- policies => the anon/auth client cannot read or redeem codes directly; the
-- service role (Edge Function) bypasses RLS for validation.
create policy "pairing_insert_own"
  on public.device_pairing_codes for insert
  with check (user_id = auth.uid());
