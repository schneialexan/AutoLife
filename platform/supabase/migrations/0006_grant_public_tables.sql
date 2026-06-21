-- Backfill table grants for the public tables created in 0001.
--
-- Migration 0001 originally created public.profiles and
-- public.device_pairing_codes without explicit GRANTs. On hosted projects this
-- left the Supabase roles (anon/authenticated/service_role) without DML, so the
-- service-role `pair-device` Edge Function failed with
-- "permission denied for table device_pairing_codes" when creating a code.
--
-- 0001 now grants these on fresh installs; this migration converges existing
-- databases. Idempotent: re-granting is a no-op. RLS still gates row access.

grant select, insert, update, delete on table public.profiles
  to anon, authenticated, service_role;

grant select, insert, update, delete on table public.device_pairing_codes
  to anon, authenticated, service_role;
