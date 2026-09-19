-- Create the roster_sections table for PulseCAD Community Dashboard
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS roster_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roster_id UUID NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_roster_sections_roster_id ON roster_sections(roster_id);

-- Enable Row Level Security
ALTER TABLE roster_sections ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can manage roster sections" ON roster_sections;

-- Policy: Allow authenticated users to manage roster sections
CREATE POLICY "Users can manage roster sections"
    ON roster_sections FOR ALL
    TO authenticated
    USING (true);

-- Grant permissions
GRANT ALL ON roster_sections TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;