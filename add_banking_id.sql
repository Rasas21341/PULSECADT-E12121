-- Add banking_id to civilians for the Civilian Banking feature.
-- Run this in the Supabase SQL editor.

alter table if exists public.civilians
    add column if not exists banking_id text;

create index if not exists civilians_banking_id_idx
    on public.civilians (banking_id);
