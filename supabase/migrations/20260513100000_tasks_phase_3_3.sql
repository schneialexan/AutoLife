-- Phase 3.3: task engine, templates, comments, My Day history, task-block calendar links.

-- ---------------------------------------------------------------------------
-- calendar_events: task block linkage
-- ---------------------------------------------------------------------------
alter table public.calendar_events
  add column if not exists is_task_block boolean not null default false;

alter table public.calendar_events
  add column if not exists linked_task_id uuid;

create index if not exists calendar_events_linked_task_idx
  on public.calendar_events (family_id, linked_task_id)
  where linked_task_id is not null;

comment on column public.calendar_events.is_task_block is 'True when event row is a scheduled work block for auto_tasks.';
comment on column public.calendar_events.linked_task_id is 'FK to tasks.id when is_task_block; soft reference (no DB FK for offline ordering).';

-- ---------------------------------------------------------------------------
-- task_lists
-- ---------------------------------------------------------------------------
create table public.task_lists (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  name text not null,
  icon_name text not null default 'list',
  color_hex text,
  default_assignee_id uuid,
  sharing_scope jsonb,
  is_smart boolean not null default false,
  smart_rule jsonb,
  position int not null default 0,
  archived boolean not null default false,
  default_reminder_minutes_before_due int,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index task_lists_family_position_idx on public.task_lists (family_id, position);

-- ---------------------------------------------------------------------------
-- tasks
-- ---------------------------------------------------------------------------
create table public.tasks (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  list_id uuid not null references public.task_lists (id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'inbox',
  priority text not null default 'medium',
  importance boolean not null default false,
  due_at timestamptz,
  scheduled_for timestamptz,
  estimated_duration_ms int,
  my_day_date date,
  reminders jsonb not null default '[]'::jsonb,
  recurrence jsonb,
  series_id uuid,
  exception_original_due timestamptz,
  steps jsonb not null default '[]'::jsonb,
  tags text[] not null default '{}',
  attachments jsonb not null default '[]'::jsonb,
  links jsonb not null default '[]'::jsonb,
  assignee_ids uuid[] not null default '{}',
  comments_count int not null default 0,
  related_asset_ids uuid[] not null default '{}',
  related_event_ids uuid[] not null default '{}',
  source_event_id uuid,
  scheduled_event_id uuid,
  source_task_id uuid,
  source_module text,
  completed_at timestamptz,
  completed_by uuid,
  canceled_at timestamptz,
  canceled_by uuid,
  color text,
  requires_approval boolean not null default false,
  created_by uuid not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index tasks_family_due_idx on public.tasks (family_id, due_at);
create index tasks_family_list_status_idx on public.tasks (family_id, list_id, status);
create index tasks_family_scheduled_idx on public.tasks (family_id, scheduled_for);
create unique index tasks_family_source_event_key on public.tasks (family_id, source_event_id)
  where source_event_id is not null;

-- ---------------------------------------------------------------------------
-- task_dependencies
-- ---------------------------------------------------------------------------
create table public.task_dependencies (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  prerequisite_task_id uuid not null references public.tasks (id) on delete cascade,
  created_at timestamptz not null default now (),
  constraint task_dependencies_unique unique (task_id, prerequisite_task_id),
  constraint task_dependencies_no_self check (task_id <> prerequisite_task_id)
);

create index task_dependencies_family_idx on public.task_dependencies (family_id);

-- ---------------------------------------------------------------------------
-- task_list_shares
-- ---------------------------------------------------------------------------
create table public.task_list_shares (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  list_id uuid not null references public.task_lists (id) on delete cascade,
  grantee_profile_id uuid,
  guest_link_token text,
  permission text not null default 'read',
  created_by uuid not null,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint task_list_shares_grantee_or_guest check (
    grantee_profile_id is not null or guest_link_token is not null
  )
);

create index task_list_shares_family_list_idx on public.task_list_shares (family_id, list_id);

-- ---------------------------------------------------------------------------
-- task_templates + versions
-- ---------------------------------------------------------------------------
create table public.task_templates (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  name text not null,
  tasks_blueprint jsonb not null default '[]'::jsonb,
  version int not null default 1,
  created_by uuid,
  row_version int not null default 1,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now ()
);

create index task_templates_family_idx on public.task_templates (family_id, name);

create table public.task_template_versions (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  template_id uuid not null references public.task_templates (id) on delete cascade,
  version int not null,
  tasks_blueprint jsonb not null,
  created_by uuid,
  created_at timestamptz not null default now (),
  constraint task_template_versions_unique unique (template_id, version)
);

-- ---------------------------------------------------------------------------
-- task_comments
-- ---------------------------------------------------------------------------
create table public.task_comments (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  author_id uuid not null,
  body text not null,
  parent_id uuid references public.task_comments (id) on delete cascade,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now ()
);

create index task_comments_task_idx on public.task_comments (family_id, task_id);

-- ---------------------------------------------------------------------------
-- task_my_day_history
-- ---------------------------------------------------------------------------
create table public.task_my_day_history (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  profile_id uuid not null,
  day date not null,
  action text not null default 'added',
  created_at timestamptz not null default now ()
);

create index task_my_day_history_task_day_idx
  on public.task_my_day_history (family_id, task_id, day desc);

-- ---------------------------------------------------------------------------
-- task_completion_reactions
-- ---------------------------------------------------------------------------
create table public.task_completion_reactions (
  id uuid primary key default gen_random_uuid (),
  family_id uuid not null references public.families (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  profile_id uuid not null,
  emoji text not null,
  created_at timestamptz not null default now (),
  constraint task_completion_reactions_unique unique (task_id, profile_id)
);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table public.task_lists enable row level security;
alter table public.tasks enable row level security;
alter table public.task_dependencies enable row level security;
alter table public.task_list_shares enable row level security;
alter table public.task_templates enable row level security;
alter table public.task_template_versions enable row level security;
alter table public.task_comments enable row level security;
alter table public.task_my_day_history enable row level security;
alter table public.task_completion_reactions enable row level security;

create policy task_lists_member on public.task_lists for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy tasks_member on public.tasks for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_dependencies_member on public.task_dependencies for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_list_shares_member on public.task_list_shares for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_templates_member on public.task_templates for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_template_versions_member on public.task_template_versions for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_comments_member on public.task_comments for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_my_day_member on public.task_my_day_history for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

create policy task_completion_reactions_member on public.task_completion_reactions for all to authenticated using (public.is_member_of (family_id))
with check (public.is_member_of (family_id));

insert into public.sensitivity_assignments (table_schema, table_name, column_name, tier)
values
  ('public', 'task_lists', 'sharing_scope', 'public_family'),
  ('public', 'tasks', 'description', 'public_family'),
  ('public', 'tasks', 'attachments', 'public_family'),
  ('public', 'task_comments', 'body', 'public_family')
on conflict (table_schema, table_name, column_name) do update set
  tier = excluded.tier,
  updated_at = now ();
