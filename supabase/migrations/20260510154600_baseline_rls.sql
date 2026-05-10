-- Baseline RLS policies for AutoLife (Milestone 1)

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to anon, authenticated;

create or replace function private.current_family_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select family_id
  from public.profiles
  where id = (select auth.uid())
  limit 1
$$;

grant execute on function private.current_family_id() to anon, authenticated;

-- families: members can read their own family
create policy "family_members_select" on public.families
  for select using (
    id = (select private.current_family_id())
  );

-- profiles: read own family, update own row
create policy "profiles_select_family" on public.profiles
  for select using (
    family_id = (select private.current_family_id())
  );

create policy "profiles_update_own" on public.profiles
  for update using (
    id = (select auth.uid())
  )
  with check (
    id = (select auth.uid())
    and family_id = (select private.current_family_id())
  );

-- system_events: insert + read own family only
create policy "events_insert_family" on public.system_events
  for insert with check (
    family_id = (select private.current_family_id())
  );

create policy "events_select_family" on public.system_events
  for select using (
    family_id = (select private.current_family_id())
  );

-- event_deliveries: read own family events only
create policy "deliveries_select_family" on public.event_deliveries
  for select using (
    exists (
      select 1
      from public.system_events
      where system_events.id = event_deliveries.event_id
        and system_events.family_id = (select private.current_family_id())
    )
  );

