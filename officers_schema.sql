-- ============================================
-- Fix: Add missing columns to the existing officers table
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.
-- ============================================

-- 1. Ensure the community_id column exists on the officers table
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS community_id BIGINT;

-- 2. Ensure the officer_id column exists (used for upserts)
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS officer_id TEXT;

-- 3. Ensure name, rank, callsign, status, updated_at exist
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS rank TEXT;
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS callsign TEXT;
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'available';
ALTER TABLE IF EXISTS public.officers
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 4. Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_officers_community ON officers(community_id);
CREATE INDEX IF NOT EXISTS idx_officers_officer_id ON officers(officer_id);
CREATE INDEX IF NOT EXISTS idx_officers_updated ON officers(updated_at DESC);

-- 4b. Unique constraint on officer_id so upsert works
ALTER TABLE officers DROP CONSTRAINT IF EXISTS officers_officer_id_key;
ALTER TABLE officers ADD CONSTRAINT officers_officer_id_key UNIQUE (officer_id);

-- 5. Enable RLS
ALTER TABLE officers ENABLE ROW LEVEL SECURITY;

-- 6. Policies (idempotent - safe to re-run)
DROP POLICY IF EXISTS "Anyone can view officers" ON officers;
CREATE POLICY "Anyone can view officers" ON officers
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can insert officers" ON officers;
CREATE POLICY "Anyone can insert officers" ON officers
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Anyone can update officers" ON officers;
CREATE POLICY "Anyone can update officers" ON officers
    FOR UPDATE USING (true);

-- 7. Enable realtime for the officers table
ALTER TABLE officers REPLICA IDENTITY FULL;

-- 8. Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! The Units bar will now show officers in real time.
-- ============================================