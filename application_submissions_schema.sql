-- Application submissions (answers from users)
CREATE TABLE application_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    user_email TEXT,
    answers JSONB NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_application_submissions_application_id ON application_submissions(application_id);
CREATE INDEX idx_application_submissions_user_id ON application_submissions(user_id);

-- RLS
ALTER TABLE application_submissions DISABLE ROW LEVEL SECURITY;

-- For production:
-- ALTER TABLE application_submissions ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view their own submissions" ON application_submissions
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