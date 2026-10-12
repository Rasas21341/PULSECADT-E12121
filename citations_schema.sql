-- ============================================
-- Citations table + realistic citation fields
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.
-- ============================================

-- Citations table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS citations (
    id BIGSERIAL PRIMARY KEY,
    citation_number TEXT,                 -- e.g. CIT-abc123-xy7f
    civilian_id TEXT,
    civilian_name TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    statute TEXT,                         -- e.g. 18 U.S.C. § 1001, VC 23152
    reason TEXT,
    location TEXT,
    fine NUMERIC,                         -- dollars
    vehicle_make TEXT,
    vehicle_model TEXT,
    vehicle_plate TEXT,
    court_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_citations_officer ON citations(officer_id);
CREATE INDEX IF NOT EXISTS idx_citations_civilian ON citations(civilian_id);
CREATE INDEX IF NOT EXISTS idx_citations_created ON citations(created_at DESC);

-- Enable RLS
ALTER TABLE citations ENABLE ROW LEVEL SECURITY;

-- Policy: Officers can view citations they created
CREATE POLICY "Officers can view own citations" ON citations
    FOR SELECT USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Officers can insert their own citations
CREATE POLICY "Officers can insert own citations" ON citations
    FOR INSERT WITH CHECK (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Policy: Officers can delete their own citations
CREATE POLICY "Officers can delete own citations" ON citations
    FOR DELETE USING (officer_id = current_setting('request.jwt.claims', true)::json->>'sub');

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! Check the Police -> Units / Citations panel to verify.
-- ============================================