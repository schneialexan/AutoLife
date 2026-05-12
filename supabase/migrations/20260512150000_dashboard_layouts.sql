-- Phase 3.1.5: persisted dashboard layouts (personal + optional family default row).

create table public.dashboard_layouts (
  family_id uuid not null references public.families (id) on delete cascade,
  member_scope text not null,
  layout_json jsonb not null default '{"schema":2,"base":[],"overrides":{}}'::jsonb,
  layout_version int not null default 1,
  updated_at timestamptz not null default now(),
  primary key (family_id, member_scope)
);

comment on table public.dashboard_layouts is 'Home dashboard JSON; member_scope __family_default__ is the owner-only family default seed.';

create index dashboard_layouts_family_idx on public.dashboard_layouts (family_id);

alter table public.dashboard_layouts enable row level security;

create policy dashboard_layouts_select_member on public.dashboard_layouts
  for select using (
    exists (
      select 1
      from public.memberships m
      where
        m.family_id = dashboard_layouts.family_id
        and m.user_id = auth.uid ()
        and m.removed_at is null
    )
  );

create policy dashboard_layouts_write on public.dashboard_layouts
  for insert
  with check (
    exists (
      select 1
      from public.memberships m
      where
        m.family_id = dashboard_layouts.family_id
        and m.user_id = auth.uid ()
        and m.removed_at is null
    )
    and (
      member_scope = auth.uid ()::text
      or (
        member_scope = '__family_default__'
        and exists (
          select 1
          from public.memberships mo
          where
            mo.family_id = dashboard_layouts.family_id
            and mo.user_id = auth.uid ()
            and mo.role = 'owner'::public.family_role
            and mo.removed_at is null
        )
      )
    )
  );

create policy dashboard_layouts_update on public.dashboard_layouts
  for update using (
    exists (
      select 1
      from public.memberships m
      where
        m.family_id = dashboard_layouts.family_id
        and m.user_id = auth.uid ()
        and m.removed_at is null
    )
    and (
      member_scope = auth.uid ()::text
      or (
        member_scope = '__family_default__'
        and exists (
          select 1
          from public.memberships mo
          where
            mo.family_id = dashboard_layouts.family_id
            and mo.user_id = auth.uid ()
            and mo.role = 'owner'::public.family_role
            and mo.removed_at is null
        )
      )
    )
  )
  with check (
    member_scope = auth.uid ()::text
    or (
      member_scope = '__family_default__'
      and exists (
        select 1
        from public.memberships mo
        where
          mo.family_id = dashboard_layouts.family_id
          and mo.user_id = auth.uid ()
          and mo.role = 'owner'::public.family_role
          and mo.removed_at is null
      )
    )
  );

create policy dashboard_layouts_delete on public.dashboard_layouts
  for delete using (
    exists (
      select 1
      from public.memberships m
      where
        m.family_id = dashboard_layouts.family_id
        and m.user_id = auth.uid ()
        and m.removed_at is null
    )
    and (
      member_scope = auth.uid ()::text
      or (
        member_scope = '__family_default__'
        and exists (
          select 1
          from public.memberships mo
          where
            mo.family_id = dashboard_layouts.family_id
            and mo.user_id = auth.uid ()
            and mo.role = 'owner'::public.family_role
            and mo.removed_at is null
        )
      )
    )
  );
