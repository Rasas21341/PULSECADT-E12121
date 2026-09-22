-- ============================================
-- PulseCAD Member Roles Table
-- Links community members to roles defined in the
-- community's "roles" table. Run this in the Supabase
-- SQL editor.
--
-- A member can have one role at a time within a community.
-- ============================================

CREATE TABLE IF NOT EXISTS member_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id TEXT NOT NULL,
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(community_id, user_id, role_id)
);

CREATE INDEX IF NOT EXISTS idx_member_roles_community_id ON member_roles(community_id);
CREATE INDEX IF NOT EXISTS idx_member_roles_user_id ON member_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_member_roles_role_id ON member_roles(role_id);

ALTER TABLE member_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage member roles" ON member_roles;
CREATE POLICY "Users can manage member roles"
    ON member_roles FOR ALL
    TO authenticated
    USING (true);

GRANT ALL ON member_roles TO authenticated;

-- ============================================
-- Setup Complete!
-- ============================================
