-- ============================================
-- Save / update the Extraditable flag on a warrant
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- 1) Ensure the column exists (adds it if the table was created before this field)
ALTER TABLE warrants ADD COLUMN IF NOT EXISTS extraditable BOOLEAN DEFAULT false;

-- 2) Make sure RLS is enabled so updates are allowed
ALTER TABLE warrants ENABLE ROW LEVEL SECURITY;

-- 3) Idempotent update policy (create only if it doesn't already exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policy WHERE polname = 'Officers can update warrants') THEN
        CREATE POLICY "Officers can update warrants" ON warrants
            FOR UPDATE USING (true);
    END IF;
END $$;

-- 4) Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Example usage (uncomment and edit the values):
-- UPDATE warrants
--    SET extraditable = true
--    WHERE warrant_number = 'WR-xxxxxxxx';
-- ============================================