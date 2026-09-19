-- PulseCAD Rosters - All Tables
-- Run this entire script in your Supabase SQL Editor

-- 1. Rosters Table
CREATE TABLE IF NOT EXISTS rosters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_rosters_community_id ON rosters(community_id);
CREATE INDEX IF NOT EXISTS idx_rosters_created_at ON rosters(created_at DESC);
ALTER TABLE rosters ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage rosters" ON rosters;
CREATE POLICY "Users can manage rosters" ON rosters FOR ALL TO authenticated USING (true);
GRANT ALL ON rosters TO authenticated;

-- 2. Roster Members Table
CREATE TABLE IF NOT EXISTS roster_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roster_id UUID NOT NULL,
    member_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(roster_id, member_id)
);
CREATE INDEX IF NOT EXISTS idx_roster_members_roster_id ON roster_members(roster_id);
CREATE INDEX IF NOT EXISTS idx_roster_members_member_id ON roster_members(member_id);
ALTER TABLE roster_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage roster members" ON roster_members;
CREATE POLICY "Users can manage roster members" ON roster_members FOR ALL TO authenticated USING (true);
GRANT ALL ON roster_members TO authenticated;

-- 3. Roster Sections Table
CREATE TABLE IF NOT EXISTS roster_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roster_id UUID NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_roster_sections_roster_id ON roster_sections(roster_id);
ALTER TABLE roster_sections ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage roster sections" ON roster_sections;
CREATE POLICY "Users can manage roster sections" ON roster_sections FOR ALL TO authenticated USING (true);
GRANT ALL ON roster_sections TO authenticated;

-- 4. Roster Roles Table
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
CREATE POLICY "Users can manage roster roles" ON roster_roles FOR ALL TO authenticated USING (true);
GRANT ALL ON roster_roles TO authenticated;