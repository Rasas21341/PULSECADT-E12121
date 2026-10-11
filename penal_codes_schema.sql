-- Create penal_codes table
CREATE TABLE IF NOT EXISTS penal_codes (
    id BIGSERIAL PRIMARY KEY,
    community_id BIGINT REFERENCES communities(id) ON DELETE CASCADE,
    title TEXT NOT NULL,           -- Statute name (e.g., "Murder", "Assault")
    code TEXT,                     -- Code/Section (e.g., "PC 187", "VC 23152")
    description TEXT,              -- Description of the offense
    classification TEXT DEFAULT 'Misdemeanor',  -- Misdemeanor, Felony, Infraction
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE penal_codes ENABLE ROW LEVEL SECURITY;

-- Policy: Community members can view penal codes
CREATE POLICY "Community members can view penal codes" ON penal_codes
    FOR SELECT USING (
        community_id IN (
            SELECT community_id FROM user_communities WHERE user_id = auth.uid()
        )
    );

-- Policy: Management/Supervisors can insert penal codes
CREATE POLICY "Management can insert penal codes" ON penal_codes
    FOR INSERT WITH CHECK (
        community_id IN (
            SELECT community_id FROM user_communities WHERE user_id = auth.uid()
        )
    );

-- Policy: Management/Supervisors can update penal codes
CREATE POLICY "Management can update penal codes" ON penal_codes
    FOR UPDATE USING (
        community_id IN (
            SELECT community_id FROM user_communities WHERE user_id = auth.uid()
        )
    );

-- Policy: Management/Supervisors can delete penal codes
CREATE POLICY "Management can delete penal codes" ON penal_codes
    FOR DELETE USING (
        community_id IN (
            SELECT community_id FROM user_communities WHERE user_id = auth.uid()
        )
    );

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_penal_codes_community ON penal_codes(community_id);