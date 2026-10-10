-- Make oceanviewrp1@gmail.com Management.
-- There are two rows for that email (one already Management, one Unassigned);
-- the app now resolves department by auth user id, so set BOTH rows to
-- Management to guarantee the lookup always succeeds regardless of which
-- auth uid is in the session.
--
-- Run this ENTIRE script in the Supabase SQL Editor and click RUN.

UPDATE public.users
SET department = 'Management'
WHERE email = 'oceanviewrp1@gmail.com';

-- Refresh PostgREST schema cache.
NOTIFY pgrst, 'reload schema';

-- ============================================
-- Done!
-- ============================================