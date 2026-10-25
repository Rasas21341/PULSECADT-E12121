-- ============================================
-- Documents table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN
-- ============================================

-- Documents table (create if it does not already exist)
CREATE TABLE IF NOT EXISTS public.documents (
    id BIGSERIAL PRIMARY KEY,
    community_id TEXT,
    title TEXT,
    departments TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_documents_community ON public.documents(community_id);

-- Enable RLS
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone authenticated can view documents
CREATE POLICY "Authenticated users can view documents" ON public.documents
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Anyone authenticated can insert documents
CREATE POLICY "Authenticated users can insert documents" ON public.documents
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Anyone authenticated can delete documents
CREATE POLICY "Authenticated users can delete documents" ON public.documents
    FOR DELETE USING (auth.role() = 'authenticated');

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================