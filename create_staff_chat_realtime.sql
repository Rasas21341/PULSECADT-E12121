-- ============================================
-- PulseCAD Staff Chat Table - With Realtime
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

-- Drop existing table and policies first
DROP TABLE IF EXISTS staff_chat CASCADE;

-- 1. Staff Chat Table
CREATE TABLE IF NOT EXISTS staff_chat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    sender_name TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staff_chat_created_at ON staff_chat(created_at DESC);

ALTER TABLE staff_chat ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Staff can view chat" ON staff_chat;
DROP POLICY IF EXISTS "Staff can insert chat" ON staff_chat;

-- Policy: Allow authenticated users to view chat
CREATE POLICY "Staff can view chat"
    ON staff_chat FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Allow authenticated users to insert chat
CREATE POLICY "Staff can insert chat"
    ON staff_chat FOR INSERT
    TO authenticated
    WITH CHECK (true);

GRANT ALL ON staff_chat TO authenticated;

-- 2. Enable Realtime for staff_chat table
ALTER PUBLICATION supabase_realtime ADD TABLE staff_chat;

-- ============================================
-- Setup Complete!
-- ============================================