-- Add a "banner" column to the communities table so community banners can be saved in Supabase.
-- Run this in the Supabase SQL editor.

ALTER TABLE public.communities
    ADD COLUMN IF NOT EXISTS banner TEXT;

-- Ensure authenticated users can update the banner column on their own communities.
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "communities_update_banner" ON public.communities;
CREATE POLICY "communities_update_banner"
    ON public.communities FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);
