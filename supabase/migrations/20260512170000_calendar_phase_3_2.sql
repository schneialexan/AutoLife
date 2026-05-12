-- Phase 3.2: calendar events, recurrence exceptions, external sync links, import batches.

-- ---------------------------------------------------------------------------
-- calendar_events
-- ---------------------------------------------------------------------------
create table public.calendar_events (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  title text not null,
  description text,
  notes text,
  location text,
  start_at timestamptz not null,
  end_at timestamptz not null,
  all_day boolean not null default false,
  assigned_to uuid,
  tagged_members uuid[] not null default '{}',
  created_by uuid not null,
  color text,
  sync_source text not null default 'internal',
  external_id text,
  provider text,
  external_uid text,
  synced_by_user_id uuid,
  last_synced_at timestamptz,
  recurrence jsonb,
  reminders jsonb not null default '[]'::jsonb,
  commute_meta jsonb,
  series_id uuid,
  exception_original_start timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_events_time_order check (end_at >= start_at)
);

create index calendar_events_family_start_idx on public.calendar_events (family_id, start_at);
create index calendar_events_family_updated_idx on public.calendar_events (family_id, updated_at);
create unique index calendar_events_family_external_uid_key on public.calendar_events (family_id, provider, external_uid)
where
  provider is not null
  and external_uid is not null;

comment on table public.calendar_events is 'Phase 3.2: family-scoped calendar events; sync + recurrence JSON mirrors autolife-core.';
comment on column public.calendar_events.external_uid is 'Stable provider id for idempotent upserts (google ical UID, etc.).';
comment on column public.calendar_events.recurrence is 'Serialized CalendarRecurrenceRule + exception anchors; see autolife-core calendar_recurrence.';

-- ---------------------------------------------------------------------------
-- calendar_recurrence_exceptions
-- ---------------------------------------------------------------------------
create table public.calendar_recurrence_exceptions (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  series_id uuid not null,
  original_occurrence_start timestamptz not null,
  exception_event_id uuid references public.calendar_events (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_recurrence_exceptions_series_unique unique (series_id, original_occurrence_start)
);

create index calendar_recurrence_exceptions_family_idx on public.calendar_recurrence_exceptions (family_id);

comment on table public.calendar_recurrence_exceptions is 'Explicit recurrence exception rows; preserved across offline replay.';

-- ---------------------------------------------------------------------------
-- calendar_sync_links (integration gateway external calendar binding)
-- ---------------------------------------------------------------------------
create table public.calendar_sync_links (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  provider text not null,
  account_label text,
  external_calendar_id text not null,
  status text not null default 'active',
  last_cursor jsonb,
  last_synced_at timestamptz,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint calendar_sync_links_family_provider_calendar unique (family_id, provider, external_calendar_id)
);

create index calendar_sync_links_family_idx on public.calendar_sync_links (family_id);

comment on table public.calendar_sync_links is 'Bindings to Google/Apple/Outlook calendars via integration gateway; credential refs live in vault.';

-- ---------------------------------------------------------------------------
-- calendar_import_batches
-- ---------------------------------------------------------------------------
create table public.calendar_import_batches (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  source text not null,
  idempotency_key text not null,
  status text not null default 'pending',
  summary jsonb not null default '{}'::jsonb,
  unsupported_fields text[] not null default '{}',
  created_by uuid not null,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint calendar_import_batches_family_ik unique (family_id, idempotency_key)
);

create index calendar_import_batches_family_created_idx on public.calendar_import_batches (family_id, created_at desc);

comment on table public.calendar_import_batches is 'ICS / provider import runs with preview stats + dedupe summary; idempotent per idempotency_key.';

-- ---------------------------------------------------------------------------
-- RLS (per-family membership template)
-- ---------------------------------------------------------------------------
alter table public.calendar_events enable row level security;
alter table public.calendar_recurrence_exceptions enable row level security;
alter table public.calendar_sync_links enable row level security;
alter table public.calendar_import_batches enable row level security;

create policy calendar_events_member on public.calendar_events for all to authenticated using (public.is_member_of (family_id))
with
  check (public.is_member_of (family_id));

create policy calendar_recurrence_exceptions_member on public.calendar_recurrence_exceptions for all to authenticated using (public.is_member_of (family_id))
with
  check (public.is_member_of (family_id));

create policy calendar_sync_links_member on public.calendar_sync_links for all to authenticated using (public.is_member_of (family_id))
with
  check (public.is_member_of (family_id));

create policy calendar_import_batches_member on public.calendar_import_batches for all to authenticated using (public.is_member_of (family_id))
with
  check (public.is_member_of (family_id));

grant select, insert, update, delete on table public.calendar_events to authenticated;
grant select, insert, update, delete on table public.calendar_recurrence_exceptions to authenticated;
grant select, insert, update, delete on table public.calendar_sync_links to authenticated;
grant select, insert, update, delete on table public.calendar_import_batches to authenticated;

insert into public.sensitivity_assignments (table_schema, table_name, column_name, tier)
values
  ('public', 'calendar_events', 'id', 'public_family'),
  ('public', 'calendar_events', 'family_id', 'public_family'),
  ('public', 'calendar_events', 'title', 'public_family'),
  ('public', 'calendar_events', 'description', 'public_family'),
  ('public', 'calendar_events', 'notes', 'public_family'),
  ('public', 'calendar_events', 'location', 'public_family'),
  ('public', 'calendar_events', 'start_at', 'public_family'),
  ('public', 'calendar_events', 'end_at', 'public_family'),
  ('public', 'calendar_events', 'all_day', 'public_family'),
  ('public', 'calendar_events', 'assigned_to', 'public_family'),
  ('public', 'calendar_events', 'tagged_members', 'public_family'),
  ('public', 'calendar_events', 'created_by', 'public_family'),
  ('public', 'calendar_events', 'color', 'public_family'),
  ('public', 'calendar_events', 'sync_source', 'public_family'),
  ('public', 'calendar_events', 'external_id', 'public_family'),
  ('public', 'calendar_events', 'provider', 'public_family'),
  ('public', 'calendar_events', 'external_uid', 'public_family'),
  ('public', 'calendar_events', 'synced_by_user_id', 'public_family'),
  ('public', 'calendar_events', 'last_synced_at', 'public_family'),
  ('public', 'calendar_events', 'recurrence', 'public_family'),
  ('public', 'calendar_events', 'reminders', 'public_family'),
  ('public', 'calendar_events', 'commute_meta', 'public_family'),
  ('public', 'calendar_events', 'series_id', 'public_family'),
  ('public', 'calendar_events', 'exception_original_start', 'public_family'),
  ('public', 'calendar_events', 'created_at', 'public_family'),
  ('public', 'calendar_events', 'updated_at', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'id', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'family_id', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'series_id', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'original_occurrence_start', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'exception_event_id', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'created_at', 'public_family'),
  ('public', 'calendar_recurrence_exceptions', 'updated_at', 'public_family'),
  ('public', 'calendar_sync_links', 'id', 'public_family'),
  ('public', 'calendar_sync_links', 'family_id', 'public_family'),
  ('public', 'calendar_sync_links', 'provider', 'public_family'),
  ('public', 'calendar_sync_links', 'account_label', 'public_family'),
  ('public', 'calendar_sync_links', 'external_calendar_id', 'public_family'),
  ('public', 'calendar_sync_links', 'status', 'public_family'),
  ('public', 'calendar_sync_links', 'last_cursor', 'public_family'),
  ('public', 'calendar_sync_links', 'last_synced_at', 'public_family'),
  ('public', 'calendar_sync_links', 'created_by', 'public_family'),
  ('public', 'calendar_sync_links', 'created_at', 'public_family'),
  ('public', 'calendar_sync_links', 'updated_at', 'public_family'),
  ('public', 'calendar_import_batches', 'id', 'public_family'),
  ('public', 'calendar_import_batches', 'family_id', 'public_family'),
  ('public', 'calendar_import_batches', 'source', 'public_family'),
  ('public', 'calendar_import_batches', 'idempotency_key', 'public_family'),
  ('public', 'calendar_import_batches', 'status', 'public_family'),
  ('public', 'calendar_import_batches', 'summary', 'public_family'),
  ('public', 'calendar_import_batches', 'unsupported_fields', 'public_family'),
  ('public', 'calendar_import_batches', 'created_by', 'public_family'),
  ('public', 'calendar_import_batches', 'created_at', 'public_family'),
  ('public', 'calendar_import_batches', 'updated_at', 'public_family')
on conflict (table_schema, table_name, column_name) do update set
  tier = excluded.tier,
  updated_at = now ();
