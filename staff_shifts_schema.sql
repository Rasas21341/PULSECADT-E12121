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

-- Policy: Moderators/management can view shifts in their community
CREATE POLICY "Staff shifts viewable by community mods" ON public.staff_shifts
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Authenticated users can insert their own shift records
CREATE POLICY "Users can start their own shift" ON public.staff_shifts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Users can update their own shift records (end shift / break)
CREATE POLICY "Users can update their own shift" ON public.staff_shifts
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================