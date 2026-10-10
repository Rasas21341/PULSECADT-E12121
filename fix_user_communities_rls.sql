-- ============================================
-- Fix: allow authenticated users to INSERT/SELECT into user_communities
-- (the join flow). Without these policies the join button fails with
-- "new row violates row-level security policy" (42501), and the
-- "already joined" check returns nothing so every join attempt looks like
-- a duplicate.
--
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.
-- ============================================

ALTER TABLE public.user_communities ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can read join status (needed by checkUserJoined).
DROP POLICY IF EXISTS "user_communities_select_auth" ON public.user_communities;
CREATE POLICY "user_communities_select_auth"
    ON public.user_communities FOR SELECT
    TO authenticated
    USING (true);

-- Authenticated users can record their own join. The user_id must match
-- the caller's auth uid so users cannot impersonate each other.
DROP POLICY IF EXISTS "user_communities_insert_self" ON public.user_communities;
CREATE POLICY "user_communities_insert_self"
    ON public.user_communities FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Owners/moderators can update (supervisor flag, banned flag) and delete
-- (kick/ban) rows in their communities.
DROP POLICY IF EXISTS "user_communities_update_auth" ON public.user_communities;
CREATE POLICY "user_communities_update_auth"
    ON public.user_communities FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "user_communities_delete_auth" ON public.user_communities;
CREATE POLICY "user_communities_delete_auth"
    ON public.user_communities FOR DELETE
    TO authenticated
    USING (true);

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Fix Complete!
-- ============================================