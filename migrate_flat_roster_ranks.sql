-- ============================================
-- PulseCAD - Flatten roster ranks
--
-- Ranks now hang directly off the roster instead of
-- living inside a section. Run this ONCE in the
-- Supabase SQL editor.
--
-- Safe to re-run.
-- ============================================

-- 1. Add roster_id to roster_roles (if not already there)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'roster_roles'
          AND column_name = 'roster_id'
    ) THEN
        ALTER TABLE roster_roles ADD COLUMN roster_id UUID;
    END IF;
END $$;

-- 2. Backfill roster_id from the parent section so existing ranks survive
UPDATE roster_roles rr
SET roster_id = rs.roster_id
FROM roster_sections rs
WHERE rs.id = rr.section_id
  AND rr.roster_id IS NULL;

-- 3. Ranks no longer belong to a section
ALTER TABLE roster_roles ALTER COLUMN section_id DROP NOT NULL;

-- 4. Index for the new parent lookup
CREATE INDEX IF NOT EXISTS idx_roster_roles_roster_id ON roster_roles(roster_id);

-- 5. Remove ranks that could never be attributed to a roster
DELETE FROM roster_roles WHERE roster_id IS NULL;

-- Sections are no longer used by the app. Leave the table in place for now in
-- case you want to roll back; it is safe to drop later with:
--   DROP TABLE IF EXISTS roster_sections;

-- ============================================
-- Setup complete.
-- ============================================
