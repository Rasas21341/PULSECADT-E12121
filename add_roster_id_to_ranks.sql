-- ============================================
-- PulseCAD - Optional: add roster_id to roster ranks
--
-- Ranks are stored under a section (roster_sections),
-- which already carries roster_id. Adding roster_id
-- to roster_roles lets the page load every rank for a
-- roster in a single query instead of one per section.
--
-- The roster page works WITHOUT this file - it just
-- falls back to querying by section_id.
--
-- Safe to re-run.
-- ============================================

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

-- Backfill so existing ranks are reachable by the single-query path
UPDATE roster_roles rr
SET roster_id = rs.roster_id
FROM roster_sections rs
WHERE rs.id = rr.section_id
  AND rr.roster_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_roster_roles_roster_id ON roster_roles(roster_id);

-- ============================================
-- Setup complete.
-- ============================================
