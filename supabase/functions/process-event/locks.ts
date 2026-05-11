import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

export async function tryAcquireOrderingTagLease(
  client: SupabaseClient,
  orderingTag: string,
  lock: string,
  ttlSeconds = 120,
): Promise<boolean> {
  const { data, error } = await client.rpc(
    "try_acquire_ordering_tag_lease",
    {
      p_tag: orderingTag,
      p_lock: lock,
      p_ttl_seconds: ttlSeconds,
    },
  );
  if (error) throw error;
  return Boolean(data);
}

export async function releaseOrderingTagLease(
  client: SupabaseClient,
  orderingTag: string,
  lock: string,
): Promise<void> {
  const { error } = await client.rpc("release_ordering_tag_lease", {
    p_tag: orderingTag,
    p_lock: lock,
  });
  if (error) throw error;
}
