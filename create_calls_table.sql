-- Create the calls table for PulseCAD Police Panel
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS calls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nature TEXT NOT NULL,
    location TEXT NOT NULL,
    postal TEXT,
    status TEXT DEFAULT 'pending',
    units TEXT,
    caller TEXT,
    officer_id TEXT,
    officer_name TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_calls_created_at ON calls(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_calls_status ON calls(status);
CREATE INDEX IF NOT EXISTS idx_calls_officer_id ON calls(officer_id);

-- Enable Row Level Security (optional but recommended)
ALTER TABLE calls ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can create calls" ON calls;
DROP POLICY IF EXISTS "Users can view calls" ON calls;
DROP POLICY IF EXISTS "Officers can update own calls" ON calls;

-- Policy: Allow authenticated users to insert calls
CREATE POLICY "Users can create calls"
    ON calls FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Allow authenticated users to view calls
CREATE POLICY "Users can view calls"
    ON calls FOR SELECT
    TO authenticated
    USING (true);

-- Policy: Allow officers to update their own calls
CREATE POLICY "Officers can update own calls"
    ON calls FOR UPDATE
    TO authenticated
    USING (officer_id = auth.uid()::text);

-- Grant permissions
GRANT ALL ON calls TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;