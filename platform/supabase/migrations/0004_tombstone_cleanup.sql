-- Tombstone retention: purge soft-deleted rows older than the retention window
-- so deletes don't grow unbounded. Scheduled via pg_cron when available; the
-- function can also be invoked from an Edge Function on a schedule.

create or replace function assets.purge_tombstones(retention_days int default 90)
returns void
language plpgsql
security definer
set search_path = assets, public
as $$
begin
  delete from assets.items
   where deleted_at is not null
     and deleted_at < now() - make_interval(days => retention_days);

  delete from assets.category_types
   where deleted_at is not null
     and deleted_at < now() - make_interval(days => retention_days);
end;
$$;

-- Schedule daily cleanup at 03:00 UTC when pg_cron is installed. Wrapped so the
-- migration still applies on projects without the extension.
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'assets-purge-tombstones',
      '0 3 * * *',
      $cron$select assets.purge_tombstones(90);$cron$
    );
  end if;
end;
$$;
