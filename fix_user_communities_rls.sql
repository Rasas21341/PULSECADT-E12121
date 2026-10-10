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

-- Owners/moderators can update (supervisor flag, banned flag) rows in their
-- communities. A user can also toggle their own supervisor flag.
DROP POLICY IF EXISTS "user_communities_update_auth" ON public.user_communities;
CREATE POLICY "user_communities_update_auth"
    ON public.user_communities FOR UPDATE
    TO authenticated
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = user_communities.community_id
              AND c.creator_email = (SELECT email FROM auth.users WHERE id = auth.uid())
        )
    )
    WITH CHECK (true);

-- A user can delete their own row (the "Leave" flow); community creators
-- can also delete any member's row (kick/ban).
DROP POLICY IF EXISTS "user_communities_delete_auth" ON public.user_communities;
CREATE POLICY "user_communities_delete_auth"
    ON public.user_communities FOR DELETE
    TO authenticated
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.communities c
            WHERE c.id = user_communities.community_id
              AND c.creator_email = (SELECT email FROM auth.users WHERE id = auth.uid())
        )
    );

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Fix Complete!
-- ============================================