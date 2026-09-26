-- ============================================
-- PulseCAD Staff Chat Table
-- Run this SQL in your Supabase SQL Editor
-- ============================================

CREATE TABLE IF NOT EXISTS staff_chat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    sender_name TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_staff_chat_created_at ON staff_chat(created_at DESC);

ALTER TABLE staff_chat ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view chat" ON staff_chat;
CREATE POLICY "Staff can view chat"
    ON staff_chat FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.department IN ('Management', 'Support Team', 'Support Team Lead', 'Support')
        )
    );

DROP POLICY IF EXISTS "Staff can insert chat" ON staff_chat;
CREATE POLICY "Staff can insert chat"
    ON staff_chat FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.department IN ('Management', 'Support Team', 'Support Team Lead', 'Support')
        )
    );

GRANT ALL ON staff_chat TO authenticated;