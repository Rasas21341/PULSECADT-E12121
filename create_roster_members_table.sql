-- Create the roster_members table for PulseCAD Community Dashboard
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS roster_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roster_id UUID NOT NULL,
    member_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(roster_id, member_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_roster_members_roster_id ON roster_members(roster_id);
CREATE INDEX IF NOT EXISTS idx_roster_members_member_id ON roster_members(member_id);

-- Enable Row Level Security
ALTER TABLE roster_members ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can manage roster members" ON roster_members;

-- Policy: Allow authenticated users to manage roster members
CREATE POLICY "Users can manage roster members"
    ON roster_members FOR ALL
    TO authenticated
    USING (true);

-- Grant permissions
GRANT ALL ON roster_members TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;