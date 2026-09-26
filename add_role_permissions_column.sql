-- ============================================
-- Add permissions column to roles table.
-- This stores comma-separated permission names
-- (e.g. "rosters") that a role grants.
-- ============================================

ALTER TABLE IF EXISTS public.roles
    ADD COLUMN IF NOT EXISTS permissions TEXT DEFAULT '';

-- ============================================
-- Setup Complete!
-- ============================================
