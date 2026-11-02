-- ============================================
-- Staff Shifts table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN
-- ============================================

CREATE TABLE IF NOT EXISTS public.staff_shifts (
    id BIGSERIAL PRIMARY KEY,
    community_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    user_email TEXT,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    on_break BOOLEAN DEFAULT false
);

-- Index for faster lookups by community
CREATE INDEX IF NOT EXISTS idx_staff_shifts_community ON public.staff_shifts(community_id);

-- Index for finding active shifts per user
CREATE INDEX IF NOT EXISTS idx_staff_shifts_user ON public.staff_shifts(user_id, community_id);

-- Enable RLS
ALTER TABLE public.staff_shifts ENABLE ROW LEVEL SECURITY;

-- Drop old policies if they exist (safe to re-run)
DROP POLICY IF EXISTS "Staff shifts viewable by community mods" ON public.staff_shifts;
DROP POLICY IF EXISTS "Users can start their own shift" ON public.staff_shifts;
DROP POLICY IF EXISTS "Users can update their own shift" ON public.staff_shifts;
DROP POLICY IF EXISTS "Staff shifts insert" ON public.staff_shifts;

-- SELECT: any authenticated user can see active staff in any community
CREATE POLICY "Staff shifts viewable by authenticated" ON public.staff_shifts
    FOR SELECT USING (auth.role() = 'authenticated');

-- INSERT: only allow inserting your own user_id
CREATE POLICY "Users can start their own shift" ON public.staff_shifts
    FOR INSERT WITH CHECK (user_id = auth.uid()::text);

-- UPDATE: only allow updating your own shift records
CREATE POLICY "Users can update their own shift" ON public.staff_shifts
    FOR UPDATE USING (user_id = auth.uid()::text);

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================