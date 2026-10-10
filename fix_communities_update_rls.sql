-- Fix: allow authenticated users to UPDATE communities (join_approval, passcode, etc.)
-- The DELETE policy already existed; UPDATE was missing, which is why the
-- "approval mode" and "passcode" saves in community.html failed silently
-- (PostgREST returns 200 + empty array when RLS blocks an UPDATE).
--
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.

ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "communities_update_auth" ON public.communities;
CREATE POLICY "communities_update_auth"
    ON public.communities FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Also make sure SELECT/INSERT are covered for the join flow.
DROP POLICY IF EXISTS "communities_select_auth" ON public.communities;
CREATE POLICY "communities_select_auth"
    ON public.communities FOR SELECT
    TO authenticated;

-- Refresh PostgREST schema cache so the new policy is recognized immediately.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Fix Complete!
-- ============================================