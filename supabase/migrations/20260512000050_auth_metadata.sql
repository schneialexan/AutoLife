-- Phase 2.1: propagate auth.users identity metadata into tenancy stub profiles.
-- Full FK + RLS tightening ships with phase 2.2–2.4.

CREATE OR REPLACE FUNCTION public.sync_auth_profile_from_user ()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  display_name text;
BEGIN
  display_name := COALESCE(
    NULLIF(TRIM(COALESCE(NEW.raw_user_meta_data ->> 'full_name', '')), ''),
    NULLIF(TRIM(COALESCE(NEW.raw_user_meta_data ->> 'name', '')), ''),
    NULLIF(TRIM(split_part(COALESCE(NEW.email::text, ''), '@', 1)), ''),
    'AutoLife member'
  );

  INSERT INTO public.profile (id, display_name, family_id)
    VALUES (NEW.id, display_name, NULL)
  ON CONFLICT (id)
    DO UPDATE SET
      display_name = excluded.display_name;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_sync_profile ON auth.users;

CREATE TRIGGER on_auth_user_created_sync_profile
  AFTER INSERT ON auth.users FOR EACH ROW
  EXECUTE PROCEDURE public.sync_auth_profile_from_user ();

DROP TRIGGER IF EXISTS on_auth_user_metadata_sync_profile ON auth.users;

CREATE TRIGGER on_auth_user_metadata_sync_profile
  AFTER UPDATE OF raw_user_meta_data ON auth.users FOR EACH ROW
  EXECUTE PROCEDURE public.sync_auth_profile_from_user ();
