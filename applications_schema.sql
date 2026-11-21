-- Applications table (one per community)
CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    community_id BIGINT REFERENCES communities(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Questions for each application
CREATE TABLE application_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'text', -- 'text', 'textarea', 'select', 'radio', 'checkbox', 'number', 'email'
    options JSONB, -- for select/radio/checkbox: ["Option A", "Option B"]
    required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_application_questions_application_id ON application_questions(application_id);
CREATE INDEX idx_applications_community_id ON applications(community_id);

-- RLS (disable for development, enable for production)
ALTER TABLE applications DISABLE ROW LEVEL SECURITY;
ALTER TABLE application_questions DISABLE ROW LEVEL SECURITY;

-- For production, enable RLS and add policies:
-- ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE application_questions ENABLE ROW LEVEL SECURITY;

-- CREATE POLICY "Community members can view applications" ON applications
--     FOR SELECT USING (
--         community_id IN (
--             SELECT community_id FROM user_communities WHERE user_id = auth.uid()
--         )
--     );

-- CREATE POLICY "Community owners can manage applications" ON applications
--     FOR ALL USING (
--         community_id IN (
--             SELECT id FROM communities WHERE creator_email = auth.jwt() ->> 'email'
--         )
--     );

-- CREATE POLICY "Community members can view questions" ON application_questions
--     FOR SELECT USING (
--         application_id IN (
--             SELECT id FROM applications WHERE community_id IN (
--                 SELECT community_id FROM user_communities WHERE user_id = auth.uid()
--             )
--         )
--     );

-- CREATE POLICY "Community owners can manage questions" ON application_questions
--     FOR ALL USING (
--         application_id IN (
--             SELECT id FROM applications WHERE community_id IN (
--                 SELECT id FROM communities WHERE creator_email = auth.jwt() ->> 'email'
--             )
--         )
--     );