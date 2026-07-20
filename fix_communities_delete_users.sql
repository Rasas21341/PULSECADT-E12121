-- Fix "permission denied for table users" when deleting communities (Management)
-- Run this in the Supabase SQL editor.

-- 1. Make sure the public users table can be read by the API roles.
--    The communities delete RLS evaluation references the users table, and the
--    anon/authenticated roles lacked SELECT on it, causing the error.
GRANT SELECT ON TABLE public.users TO anon, authenticated;

-- 2. Ensure communities delete is allowed for authenticated staff.
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "communities_delete_auth" ON public.communities;
CREATE POLICY "communities_delete_auth"
    ON public.communities FOR DELETE
    TO authenticated
    USING (true);

-- 3. (Optional) If you prefer to fully disable RLS on communities instead,
--    uncomment the line below. Management actions are already gated in the app.
-- ALTER TABLE public.communities DISABLE ROW LEVEL SECURITY;
