-- Create the roster_roles table for PulseCAD Community Dashboard
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS roster_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_roster_roles_section_id ON roster_roles(section_id);

-- Enable Row Level Security
ALTER TABLE roster_roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can manage roster roles" ON roster_roles;

-- Policy: Allow authenticated users to manage roster roles
CREATE POLICY "Users can manage roster roles"
    ON roster_roles FOR ALL
    TO authenticated
    USING (true);

-- Grant permissions
GRANT ALL ON roster_roles TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;