-- ============================================
-- PulseCAD Roles & Role Rosters Tables
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

-- 1. Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_roles_community_id ON roles(community_id);

ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage roles" ON roles;
CREATE POLICY "Users can manage roles" 
    ON roles FOR ALL 
    TO authenticated 
    USING (true);

GRANT ALL ON roles TO authenticated;

-- 2. Role Rosters Table (links roles to rosters)
CREATE TABLE IF NOT EXISTS role_rosters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL,
    roster_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_id, roster_id)
);

CREATE INDEX IF NOT EXISTS idx_role_rosters_role_id ON role_rosters(role_id);
CREATE INDEX IF NOT EXISTS idx_role_rosters_roster_id ON role_rosters(roster_id);

ALTER TABLE role_rosters ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage role rosters" ON role_rosters;
CREATE POLICY "Users can manage role rosters" 
    ON role_rosters FOR ALL 
    TO authenticated 
    USING (true);

GRANT ALL ON role_rosters TO authenticated;

-- ============================================
-- Setup Complete!
-- ============================================