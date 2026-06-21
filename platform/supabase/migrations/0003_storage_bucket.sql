-- Private Storage bucket for blobs (receipts, photos, warranty docs).
-- Path convention: {user_id}/{module}/{record_id}/{filename}
-- Access is via signed URLs only; no public read.

insert into storage.buckets (id, name, public)
values ('user-files', 'user-files', false)
on conflict (id) do nothing;

-- RLS on storage.objects: a user may CRUD only under their own {user_id}/ prefix
-- (the first path segment must equal their auth.uid()).
create policy "user_files_select_own"
  on storage.objects for select
  using (
    bucket_id = 'user-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "user_files_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'user-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "user_files_update_own"
  on storage.objects for update
  using (
    bucket_id = 'user-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "user_files_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'user-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
