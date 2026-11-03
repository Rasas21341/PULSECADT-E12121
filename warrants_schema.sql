-- ============================================
-- Warrants table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- Warrants table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS warrants (
    id BIGSERIAL PRIMARY KEY,
    warrant_number TEXT,                    -- e.g. WR-abc123-xy7f
    civilian_id TEXT,
    civilian_name TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    type TEXT,                              -- e.g. Arrest Warrant, Bench Warrant, Traffic
    charges TEXT[] DEFAULT '{}',            -- array of charge strings
    description TEXT,
    location TEXT,
    court_date DATE,
    status TEXT DEFAULT 'Active',           -- Active, Completed, Cancelled, Expired
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_warrants_civilian ON warrants(civilian_id);
CREATE INDEX IF NOT EXISTS idx_warrants_officer ON warrants(officer_id);
CREATE INDEX IF NOT EXISTS idx_warrants_status ON warrants(status);
CREATE INDEX IF NOT EXISTS idx_warrants_created ON warrants(created_at DESC);

-- Enable RLS
ALTER TABLE warrants ENABLE ROW LEVEL SECURITY;

-- Policy: Officers can view warrants
CREATE POLICY "Officers can view warrants" ON warrants
    FOR SELECT USING (true);

-- Policy: Officers can insert warrants
CREATE POLICY "Officers can insert warrants" ON warrants
    FOR INSERT WITH CHECK (true);

-- Policy: Officers can update warrants
CREATE POLICY "Officers can update warrants" ON warrants
    FOR UPDATE USING (true);

-- Policy: Officers can delete warrants
CREATE POLICY "Officers can delete warrants" ON warrants
    FOR DELETE USING (true);

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================