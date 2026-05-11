-- Phase 1.5: DLQ view, realtime, pg_net enqueue for process-event + cron sweep, concurrency leases.

create unique index if not exists event_delivery_event_consumer_uidx on public.event_delivery (event_id, consumer);

create or replace function public.hash_ordering_tag (tag text)
returns bigint
language sql
immutable
as $$
select (hashtextextended(tag, 0))::bigint;
$$;

create or replace view public.dead_letter_event as
select
  ed.id as delivery_id,
  ed.event_id,
  ed.consumer,
  ed.attempt,
  ed.status,
  ed.last_error,
  ed.next_attempt_at,
  se.tenant_id,
  se.actor_id,
  se.module,
  se.type,
  se.payload,
  se.idempotency_key,
  se.occurred_at,
  se.ordering_tag,
  se.schema_version
from public.event_delivery ed
join public.system_event se on se.id = ed.event_id
where ed.status = 'dead_letter';

comment on view public.dead_letter_event is 'Ops DLQ surface; docs/event-bus-contract.md';

alter table public.event_delivery replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.event_delivery;
exception
  when duplicate_object then null;
end $$;

create extension if not exists pg_net with schema extensions;

-- Reachable from Postgres (Kong inside Compose). Override after link if needed.
create or replace function public.process_event_worker_base_url ()
returns text
language sql
stable
as $$
select coalesce(
  nullif(
    trim(
      both
      from
        current_setting('app.edge_process_event_base_url', true)
    ),
    ''
  ),
  'http://kong:8000'
);
$$;

create or replace function public.process_event_worker_secret ()
returns text
language sql
stable
as $$
select coalesce(
  nullif(
    trim(
      both
      from
        current_setting('app.supabase_functions_secret', true)
    ),
    ''
  ),
  -- Fallback is the documented Supabase **local demo** service_role JWT only.
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU'
);
$$;

create or replace function public.enqueue_process_event_via_net (p_event_id uuid)
returns bigint
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_url text := public.process_event_worker_base_url () || '/functions/v1/process-event';
  v_secret text := public.process_event_worker_secret ();
  v_request_id bigint;
begin
  select
    net.http_post (
      url := v_url,
      headers := case
        when length(v_secret) > 0 then jsonb_build_object(
          'Content-Type',
          'application/json',
          'Authorization',
          'Bearer ' || v_secret
        )
        else jsonb_build_object('Content-Type', 'application/json')
      end,
      body := jsonb_build_object('event_id', p_event_id)
    )
    into v_request_id;

  return v_request_id;
exception
  when others then
    raise warning 'enqueue_process_event_via_net failed: %', sqlerrm;

    return null;
end;
$$;

create or replace function public.system_event_enqueue_worker ()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform public.enqueue_process_event_via_net (new.id);

  return new;
end;
$$;

drop trigger if exists trg_system_event_process_queue on public.system_event;

drop trigger if exists system_event_enqueue_process_event_tr on public.system_event;

drop trigger if exists trg_system_event_enqueue_worker on public.system_event;

create trigger trg_system_event_enqueue_worker
after insert on public.system_event for each row
execute procedure public.system_event_enqueue_worker ();

create table if not exists public.ordering_tag_lease (
  ordering_tag text primary key,
  holder_uuid uuid not null,
  expires_at timestamptz not null default (now() + interval '2 minutes')
);

create index if not exists ordering_tag_lease_expires_idx on public.ordering_tag_lease (expires_at);

create or replace function public.try_acquire_ordering_tag_lease (
  p_tag text,
  p_lock uuid,
  p_ttl_seconds int default 120
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hold text := null;

begin
  if p_ttl_seconds <= 0 or p_ttl_seconds > 900 then
    raise exception 'invalid_ttl_seconds';
  end if;

  delete from public.ordering_tag_lease l
    where l.expires_at < now();

  insert into public.ordering_tag_lease (ordering_tag, holder_uuid, expires_at)
  values (
      p_tag,
      p_lock,
      now () + make_interval(secs => p_ttl_seconds))
  on conflict (ordering_tag) do nothing returning ordering_tag into v_hold;

  if v_hold is not null then return true; end if;

  update public.ordering_tag_lease l set
      holder_uuid = p_lock,
      expires_at = now () + make_interval(secs => p_ttl_seconds)
    where l.ordering_tag = p_tag
      and l.expires_at < now ()
  returning l.ordering_tag into v_hold;

  return v_hold is not null;
end;
$$;

create or replace function public.release_ordering_tag_lease (p_tag text, p_lock uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
delete from public.ordering_tag_lease l
  where l.ordering_tag = p_tag
    and l.holder_uuid = p_lock;
end;
$$;

create or replace function public.enqueue_event_bus_sweep_via_net ()
returns bigint
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_url text := public.process_event_worker_base_url () || '/functions/v1/process-event';
  v_secret text := public.process_event_worker_secret ();
  v_request_id bigint;
begin
  select
    net.http_post (
      url := v_url,
      headers := case
        when length(v_secret) > 0 then jsonb_build_object(
          'Content-Type',
          'application/json',
          'Authorization',
          'Bearer ' || v_secret
        )
        else jsonb_build_object('Content-Type', 'application/json')
      end,
      body := jsonb_build_object('scan_stalled', true)
    )
    into v_request_id;

  return v_request_id;
exception
  when others then
    raise warning 'enqueue_event_bus_sweep_via_net failed: %', sqlerrm;

    return null;
end;
$$;

create extension if not exists pg_cron with schema extensions;

do $$
begin
  if exists (select 1 from pg_namespace where nspname = 'cron') then
    if not exists (select 1 from cron.job where jobname = 'autolife_event_bus_sweep') then
      perform
        cron.schedule (
          'autolife_event_bus_sweep',
          '* * * * *',
          'select public.enqueue_event_bus_sweep_via_net ()'
        );
    end if;
  end if;
end $$;
