-- Add custom_code column for Pro communities
ALTER TABLE communities 
ADD COLUMN IF NOT EXISTS custom_code TEXT;

-- Index not needed for this column as it's just stored and injected