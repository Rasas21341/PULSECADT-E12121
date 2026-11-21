-- Add join_code column to communities table
ALTER TABLE communities 
ADD COLUMN IF NOT EXISTS join_code TEXT UNIQUE;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_communities_join_code ON communities(join_code);

-- Update existing communities with random join codes (run once)
UPDATE communities 
SET join_code = upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8))
WHERE join_code IS NULL;