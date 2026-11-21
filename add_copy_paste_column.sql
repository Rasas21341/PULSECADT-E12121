-- Add copy_paste_detected column to track copy/paste attempts
ALTER TABLE application_submissions 
ADD COLUMN IF NOT EXISTS copy_paste_detected BOOLEAN DEFAULT false;

-- Also add to application_submissions if it doesn't exist (for the generic application)
-- This is already in the original application.html but good to ensure
ALTER TABLE application_submissions 
ADD COLUMN IF NOT EXISTS discord TEXT,
ADD COLUMN IF NOT EXISTS age TEXT,
ADD COLUMN IF NOT EXISTS timezone TEXT,
ADD COLUMN IF NOT EXISTS active_rating INTEGER,
ADD COLUMN IF NOT EXISTS member TEXT,
ADD COLUMN IF NOT EXISTS support_reason TEXT,
ADD COLUMN IF NOT EXISTS department TEXT;