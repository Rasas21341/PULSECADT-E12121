-- ============================================
-- Fix: Add permissions column to roles table
-- and refresh PostgREST schema cache.
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

-- 1. Ensure the permissions column exists on the roles table
ALTER TABLE IF EXISTS public.roles
    ADD COLUMN IF NOT EXISTS permissions TEXT DEFAULT '';

-- 2. Add display_order column for role ordering
ALTER TABLE IF EXISTS public.roles
    ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;

-- 3. Refresh the PostgREST schema cache so Supabase recognizes the columns
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Fix Complete!
-- ============================================