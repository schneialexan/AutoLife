-- Phase 1.4 storage baseline — bucket visibility; access tightened in phase 2.4.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 52428800, null),
  ('receipts', 'receipts', false, 52428800, null),
  ('documents', 'documents', false, 52428800, null),
  ('family-assets', 'family-assets', false, 52428800, null)
on conflict (id)
do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit;

-- Avatars: public read; writes reserved for service role / later policies.
create policy "avatars_public_read"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'avatars');

-- Private buckets: no anon/authenticated policies — service_role bypasses RLS for automation.
