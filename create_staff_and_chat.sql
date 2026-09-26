-- ============================================
-- PulseCAD Staff & Staff Chat Tables
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

-- 1. Staff Table
CREATE TABLE IF NOT EXISTS staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    department TEXT NOT NULL,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_staff_user_id ON staff(user_id);
CREATE INDEX IF NOT EXISTS idx_staff_department ON staff(department);

ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view own profile" ON staff;
CREATE POLICY "Staff can view own profile"
    ON staff FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Management can view all staff" ON staff;
CREATE POLICY "Management can view all staff"
    ON staff FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.department = 'Management'
        )
        OR EXISTS (
            SELECT 1 FROM staff 
            WHERE staff.user_id = auth.uid() 
            AND staff.department = 'Management'
        )
    );

DROP POLICY IF EXISTS "Management can manage staff" ON staff;
CREATE POLICY "Management can manage staff"
    ON staff FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.department = 'Management'
        )
        OR EXISTS (
            SELECT 1 FROM staff 
            WHERE staff.user_id = auth.uid() 
            AND staff.department = 'Management'
        )
    );

GRANT ALL ON staff TO authenticated;

-- 2. Staff Chat Table
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

-- ============================================
-- Setup Complete!
-- ============================================