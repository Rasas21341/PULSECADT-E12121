-- Allow Discord-created panels to omit a Supabase auth user ID.
-- Panel ownership remains tied to creator_email.
ALTER TABLE public.communities
    ALTER COLUMN user_id DROP NOT NULL;
