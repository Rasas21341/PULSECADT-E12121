-- ============================================
-- PulseCAD Staff Table
-- Run this SQL in your Supabase SQL Editor
-- ============================================

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