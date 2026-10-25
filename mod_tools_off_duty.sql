-- ============================================
-- Add mod_tools_off_duty column to communities table
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN
-- ============================================

-- Add the column if it does not already exist
ALTER TABLE public.communities
    ADD COLUMN IF NOT EXISTS mod_tools_off_duty BOOLEAN DEFAULT false;

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================