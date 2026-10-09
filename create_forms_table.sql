-- ============================================
-- PulseCAD - Forms Table
-- Run this ONCE in the Supabase SQL editor.
-- ============================================

CREATE TABLE IF NOT EXISTS forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    form_type TEXT DEFAULT 'traffic',
    officer_name TEXT,
    officer_id TEXT,
    officer_rank TEXT,
    officer_callsign TEXT,
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_forms_created_at ON forms(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_forms_officer_id ON forms(officer_id);

ALTER TABLE forms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Police can manage forms" ON forms;
CREATE POLICY "Police can manage forms"
    ON forms FOR ALL
    TO authenticated
    USING (true);

GRANT ALL ON forms TO authenticated;

-- ============================================
-- Setup complete.
-- ============================================