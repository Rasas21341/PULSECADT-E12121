-- ============================================
-- Add judge/issuer signature to warrants
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- 1) Store signature as a data URL (PNG) captured at warrant creation
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS signature TEXT;

-- 2) Ensure RLS/update policy exists (idempotent)
ALTER TABLE warrants ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can update warrants') THEN
        CREATE POLICY "Officers can update warrants" ON warrants
            FOR UPDATE USING (true);
    END IF;
END $$;

-- 3) Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! The `signature` column stores a PNG data URL from the warrant form.
-- ============================================
