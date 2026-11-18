-- ============================================
-- Global announcements table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- Announcements table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS announcements (
    id BIGSERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    created_by TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON announcements(created_at DESC);

-- Enable RLS
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view announcements
CREATE POLICY "Authenticated users can view announcements" ON announcements
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Authenticated users can create announcements (staff panel)
CREATE POLICY "Authenticated users can create announcements" ON announcements
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete announcements
CREATE POLICY "Authenticated users can delete announcements" ON announcements
    FOR DELETE USING (auth.role() = 'authenticated');

-- Enable realtime for instant delivery to logged-in users
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables
        WHERE pubname = 'supabase_realtime' AND tablename = 'announcements'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE announcements;
    END IF;
END $$;

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================
