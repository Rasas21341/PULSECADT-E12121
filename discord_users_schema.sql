-- ============================================
-- Discord Users - saved on every Discord login
-- Works without an email/password session
-- Run in Supabase SQL Editor
-- ============================================

CREATE TABLE IF NOT EXISTS discord_users (
    discord_id TEXT PRIMARY KEY,
    username TEXT,
    display_name TEXT,
    email TEXT,
    avatar TEXT,
    first_seen TIMESTAMPTZ DEFAULT NOW(),
    last_seen TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discord_users_username ON discord_users(username);

ALTER TABLE discord_users ENABLE ROW LEVEL SECURITY;

-- Allow anyone (including anon Discord-only sessions) to read Discord users
DROP POLICY IF EXISTS "Authenticated can read discord_users" ON discord_users;
CREATE POLICY "Anyone can read discord_users" ON discord_users
    FOR SELECT USING (true);

-- Allow anyone with a session to insert/update (Discord login has no email session,
-- so we allow anon writes keyed by discord_id)
DROP POLICY IF EXISTS "Anyone can insert discord_users" ON discord_users;
CREATE POLICY "Anyone can insert discord_users" ON discord_users
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Anyone can update discord_users" ON discord_users;
CREATE POLICY "Anyone can update discord_users" ON discord_users
    FOR UPDATE USING (true) WITH CHECK (true);