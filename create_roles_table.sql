-- ============================================
-- PulseCAD Roster Roles Table
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

CREATE TABLE IF NOT EXISTS roster_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_roster_roles_section_id ON roster_roles(section_id);

ALTER TABLE roster_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage roster roles" ON roster_roles;
CREATE POLICY "Users can manage roster roles" 
    ON roster_roles FOR ALL 
    TO authenticated 
    USING (true);

GRANT ALL ON roster_roles TO authenticated;

-- ============================================
-- Setup Complete!
-- ============================================