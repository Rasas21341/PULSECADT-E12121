-- Add a "supervisor" role to community members.
-- Run this in the Supabase SQL editor.
--
-- A supervisor (set on a user_communities row) is granted elevated access in
-- connected tools — e.g. the ability to suspend/unsuspend licenses when looking
-- up a civilian in the police panel.

alter table if exists public.user_communities
    add column if not exists is_supervisor boolean not null default false;
