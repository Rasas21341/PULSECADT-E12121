-- ============================================
-- Warrants table schema (idempotent)
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- Warrants table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS warrants (
    id BIGSERIAL PRIMARY KEY,
    warrant_number TEXT,
    civilian_id TEXT,
    civilian_name TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    type TEXT,
    charges TEXT[] DEFAULT '{}',
    description TEXT,
    location TEXT,
    court_date DATE,
    status TEXT DEFAULT 'Active',
    extraditable BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add any missing columns (safe if they already exist)
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS warrant_number TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS civilian_id TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS civilian_name TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS officer_id TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS officer_name TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS officer_rank TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS officer_callsign TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS charges TEXT[] DEFAULT '{}';
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS court_date DATE;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS extraditable BOOLEAN DEFAULT false;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS judge_name TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS issuing_agency TEXT;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS issue_date DATE;
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS expiry_date DATE;

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_warrants_civilian ON warrants(civilian_id);
CREATE INDEX IF NOT EXISTS idx_warrants_officer ON warrants(officer_id);
CREATE INDEX IF NOT EXISTS idx_warrants_status ON warrants(status);
CREATE INDEX IF NOT EXISTS idx_warrants_created ON warrants(created_at DESC);

-- Enable RLS
ALTER TABLE warrants ENABLE ROW LEVEL SECURITY;

-- Policies (idempotent: create only if they do not already exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can view warrants') THEN
        CREATE POLICY "Officers can view warrants" ON warrants FOR SELECT USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can insert warrants') THEN
        CREATE POLICY "Officers can insert warrants" ON warrants FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can update warrants') THEN
        CREATE POLICY "Officers can update warrants" ON warrants FOR UPDATE USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can delete warrants') THEN
        CREATE POLICY "Officers can delete warrants" ON warrants FOR DELETE USING (true);
    END IF;
END $$;

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================