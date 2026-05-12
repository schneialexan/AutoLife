-- Phase 3.1 dashboard scaffold: per-family summary row with placeholder counts.
-- Replace aggregation body when calendar_event / task / asset tables ship (phases 3.2–3.4).

create or replace view public.dashboard_today_view
with
  (security_invoker = true) as
select
  m.family_id,
  date_trunc('day', timezone('utc', now()))::timestamptz as summary_day,
  0::bigint as event_count,
  0::bigint as task_count,
  0::bigint as warranty_signal_count
from
  public.memberships m
where
  m.removed_at is null
group by
  m.family_id;

comment on view public.dashboard_today_view is 'Phase 3.1 placeholder totals per family; calendar/tasks/assets feeds replace zeros later.';

grant select on public.dashboard_today_view to authenticated;
