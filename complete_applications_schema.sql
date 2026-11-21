-- ============================================
-- PulseCAD Application System - Complete Schema
-- Run this entire file in Supabase SQL Editor
-- ============================================

-- Applications table (one per community)
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    community_id BIGINT REFERENCES communities(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Questions for each application
CREATE TABLE IF NOT EXISTS application_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'text',
    options JSONB,
    required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Application submissions (answers from users)
CREATE TABLE IF NOT EXISTS application_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    user_email TEXT,
    answers JSONB NOT NULL,
    copy_paste_detected BOOLEAN DEFAULT false,
    discord TEXT,
    age TEXT,
    timezone TEXT,
    active_rating INTEGER,
    member TEXT,
    support_reason TEXT,
    department TEXT,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_applications_community_id ON applications(community_id);
CREATE INDEX IF NOT EXISTS idx_application_questions_application_id ON application_questions(application_id);
CREATE INDEX IF NOT EXISTS idx_application_submissions_application_id ON application_submissions(application_id);
CREATE INDEX IF NOT EXISTS idx_application_submissions_user_id ON application_submissions(user_id);

-- Ensure cascade delete on questions when application is deleted
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'application_questions_application_id_fkey' 
        AND table_name = 'application_questions'
    ) THEN
        ALTER TABLE application_questions 
        ADD CONSTRAINT application_questions_application_id_fkey 
        FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Disable RLS for development (remove for production)
ALTER TABLE applications DISABLE ROW LEVEL SECURITY;
ALTER TABLE application_questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE application_submissions DISABLE ROW LEVEL SECURITY;

-- ============================================
-- PRODUCTION RLS POLICIES (uncomment for production)
-- ============================================

-- ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE application_questions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE application_submissions ENABLE ROW LEVEL SECURITY;

-- -- Applications: community members can view, owners can manage
-- CREATE POLICY "Community members can view applications" ON applications
--     FOR SELECT USING (
--         community_id IN (
--             SELECT community_id FROM user_communities WHERE user_id = auth.uid()
--         )
-- );
-- CREATE POLICY "Community owners can manage applications" ON applications
--     FOR ALL USING (
--         community_id IN (
--             SELECT id FROM communities WHERE creator_email = auth.jwt() ->> 'email'
--         )
-- );

-- -- Questions: community members can view, owners can manage
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

-- -- Submissions: users can view own, owners can view all, authenticated can submit
-- CREATE POLICY "Users can view own submissions" ON application_submissions
--     FOR SELECT USING (user_id = auth.uid());
-- CREATE POLICY "Community owners can view all submissions" ON application_submissions
--     FOR SELECT USING (
--         application_id IN (
--             SELECT id FROM applications WHERE community_id IN (
--                 SELECT id FROM communities WHERE creator_email = auth.jwt() ->> 'email'
--             )
--         )
--     );
-- CREATE POLICY "Authenticated users can submit" ON application_submissions
--     FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);