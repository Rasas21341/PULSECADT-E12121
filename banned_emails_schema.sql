-- ============================================
-- Banned emails table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- Banned emails table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS banned_emails (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    reason TEXT,
    banned_by TEXT,
    banned_at TIMESTAMPTZ DEFAULT NOW()
);

-- Case-insensitive uniqueness for emails
CREATE UNIQUE INDEX IF NOT EXISTS idx_banned_emails_email_lower ON banned_emails (LOWER(email));

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_banned_emails_banned_at ON banned_emails(banned_at DESC);

-- Enable RLS
ALTER TABLE banned_emails ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can view banned emails (login check needs this)
CREATE POLICY "Authenticated users can view banned emails" ON banned_emails
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Service role / staff inserts happen through the anon key in the staff panel
CREATE POLICY "Authenticated users can insert banned emails" ON banned_emails
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update banned emails
CREATE POLICY "Authenticated users can update banned emails" ON banned_emails
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete (unban) banned emails
CREATE POLICY "Authenticated users can delete banned emails" ON banned_emails
    FOR DELETE USING (auth.role() = 'authenticated');

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================
