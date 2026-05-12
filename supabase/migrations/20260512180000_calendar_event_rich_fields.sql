-- Phase 3.2 follow-up: rich event fields (links, attachments, related events, attendees).

alter table public.calendar_events
  add column if not exists event_links jsonb not null default '[]'::jsonb;

alter table public.calendar_events
  add column if not exists event_attachments jsonb not null default '[]'::jsonb;

alter table public.calendar_events
  add column if not exists related_event_ids uuid[] not null default '{}';

alter table public.calendar_events
  add column if not exists event_attendees jsonb not null default '[]'::jsonb;

comment on column public.calendar_events.event_links is 'Hyperlinks (meet/docs); mirrors CalendarEventLink[] in autolife-core.';
comment on column public.calendar_events.event_attachments is 'File/image metadata; storage_path set after upload.';
comment on column public.calendar_events.related_event_ids is 'Other calendar_events in same family linked to this event.';
comment on column public.calendar_events.event_attendees is 'Guests / attendees; mirrors CalendarAttendee[] in autolife-core.';

insert into public.sensitivity_assignments (table_schema, table_name, column_name, tier)
values
  ('public', 'calendar_events', 'event_links', 'public_family'),
  ('public', 'calendar_events', 'event_attachments', 'public_family'),
  ('public', 'calendar_events', 'related_event_ids', 'public_family'),
  ('public', 'calendar_events', 'event_attendees', 'public_family')
on conflict (table_schema, table_name, column_name) do update set
  tier = excluded.tier,
  updated_at = now ();
