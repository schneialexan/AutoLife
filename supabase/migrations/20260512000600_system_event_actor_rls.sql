-- Phase 2.6 follow-up: authenticated clients write `system_event` directly
-- (see `packages/autolife-core/lib/src/services/supabase_event_producer.dart`).
-- Phase 2.4 left `system_event` with RLS enabled and zero policies, intending
-- service_role-only writes. The shell/smoke producer + connector lifecycle
-- audit both publish from the authenticated user, so we add self-actor
-- INSERT + SELECT policies. The actor_id is bound to auth.uid() so callers
-- cannot forge another user's identity.

create policy system_event_insert_self on public.system_event for insert to authenticated
with
  check (
    actor_id = (select auth.uid ())::text
  );

comment on policy system_event_insert_self on public.system_event is 'RLS template: self_insert — actor_id must equal auth.uid()::text.';

create policy system_event_select_self on public.system_event for
select to authenticated using (
  actor_id = (select auth.uid ())::text
);

comment on policy system_event_select_self on public.system_event is 'RLS template: self_select — needed so PostgREST .insert().select() returns the inserted row.';
