-- Set oceanviewrp1@gmail.com as Management and ryanmasterson2023@gmail.com as Support Team
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.

-- 1. Set oceanviewrp1@gmail.com as Management
UPDATE public.users
SET department = 'Management'
WHERE email = 'oceanviewrp1@gmail.com';

INSERT INTO public.users (id, email, department, created_at)
SELECT id, email, 'Management', NOW()
FROM auth.users
WHERE email = 'oceanviewrp1@gmail.com'
ON CONFLICT (id) DO UPDATE SET department = 'Management';

-- 2. Set ryanmasterson2023@gmail.com as Support Team
UPDATE public.users
SET department = 'Support Team'
WHERE email = 'ryanmasterson2023@gmail.com';

INSERT INTO public.users (id, email, department, created_at)
SELECT id, email, 'Support Team', NOW()
FROM auth.users
WHERE email = 'ryanmasterson2023@gmail.com'
ON CONFLICT (id) DO UPDATE SET department = 'Support Team';

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';