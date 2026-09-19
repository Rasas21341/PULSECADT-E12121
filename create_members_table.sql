-- ============================================
-- PulseCAD Members Table
-- Copy and paste this ENTIRE script into your
-- Supabase SQL Editor and click RUN
-- ============================================

CREATE TABLE IF NOT EXISTS members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id TEXT NOT NULL,
    email TEXT NOT NULL,
    name TEXT,
    role TEXT,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_members_community_id ON members(community_id);
CREATE INDEX IF NOT EXISTS idx_members_email ON members(email);

ALTER TABLE members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view members" ON members;
CREATE POLICY "Users can view members" 
    ON members FOR SELECT 
    TO authenticated 
    USING (true);

GRANT SELECT ON members TO authenticated;

-- ============================================
-- Setup Complete!
-- ============================================