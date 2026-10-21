-- Set oceanviewrp1@gmail.com as Management in the users table
-- Run this ENTIRE script in your Supabase SQL Editor and click RUN.

UPDATE public.users
SET department = 'Management'
WHERE email = 'oceanviewrp1@gmail.com';

-- Also ensure the user exists (insert if not present)
INSERT INTO public.users (id, email, department, created_at)
SELECT id, email, 'Management', NOW()
FROM auth.users
WHERE email = 'oceanviewrp1@gmail.com'
ON CONFLICT (id) DO UPDATE SET department = 'Management';

-- Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';