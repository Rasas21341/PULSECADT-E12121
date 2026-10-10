-- ============================================
-- Seed / copy departments into a community.
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.
--
-- Idempotent: deletes existing departments for the target community
-- first, then inserts the ones below. Re-running is safe.
-- ============================================

-- 1. Pick the target community id.
--    Run:  SELECT id, name FROM public.communities;
--    Then paste the id here (between the quotes on line 17).
--    Example:  '21'   -- PulseCAD Testing

-- 2. (Optional) Wipe existing departments for that community first.
--    Uncomment the DELETE line if you want to replace them entirely.
-- DELETE FROM public.departments WHERE community_id = '21';

-- 3. The departments to insert. Add/remove rows as needed.
INSERT INTO public.departments (community_id, name, type, passcode, banner)
VALUES
    -- ('<community_id>', '<department name>', '<type>', '<passcode or NULL>', '<banner url or NULL>'),
    ('21', 'Dispatch', 'Dispatch', NULL, NULL),
    ('21', 'Highway Patrol', 'Patrol', NULL, NULL),
    ('21', 'State Trooper', 'Patrol', NULL, NULL),
    ('21', 'Emergency Medical Services', 'EMS', NULL, NULL),
    ('21', 'Fire Department', 'Fire', NULL, NULL),
    ('21', 'Support Team', 'Support', NULL, NULL),
    ('21', 'Management', 'Management', NULL, NULL);

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done! Check the Departments panel to verify.
-- ============================================