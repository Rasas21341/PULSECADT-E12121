-- ============================================
-- Banking accounts table schema
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.
-- ============================================

-- Banking accounts table (create if it does not already exist)
-- One row per civilian, keyed by both civilian_id and banking_id so the
-- banking ID created on the civilian record always lines up with the balances.
CREATE TABLE IF NOT EXISTS banking_accounts (
    id BIGSERIAL PRIMARY KEY,
    civilian_id TEXT,
    banking_id TEXT UNIQUE,                 -- e.g. LC-12345 (matches civilians.banking_id)
    checking_balance NUMERIC DEFAULT 0,      -- dollars
    savings_balance NUMERIC DEFAULT 0,       -- dollars
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_banking_accounts_civilian ON banking_accounts(civilian_id);
CREATE INDEX IF NOT EXISTS idx_banking_accounts_banking_id ON banking_accounts(banking_id);

-- Enable RLS
ALTER TABLE banking_accounts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone authenticated can view banking accounts
CREATE POLICY "Authenticated users can view banking accounts" ON banking_accounts
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy: Anyone authenticated can insert banking accounts
CREATE POLICY "Authenticated users can insert banking accounts" ON banking_accounts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Policy: Anyone authenticated can update banking accounts
CREATE POLICY "Authenticated users can update banking accounts" ON banking_accounts
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================