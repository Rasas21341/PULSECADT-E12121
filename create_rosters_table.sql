-- Create the rosters table for PulseCAD Community Dashboard
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS rosters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_rosters_community_id ON rosters(community_id);
CREATE INDEX IF NOT EXISTS idx_rosters_created_at ON rosters(created_at DESC);

-- Enable Row Level Security
ALTER TABLE rosters ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can manage rosters" ON rosters;

-- Policy: Allow community creators to manage rosters
CREATE POLICY "Users can manage rosters"
    ON rosters FOR ALL
    TO authenticated
    USING (true);

-- Grant permissions
GRANT ALL ON rosters TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;