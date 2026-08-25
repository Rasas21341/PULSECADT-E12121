-- Create the insurance_cards table for the Civilian "Insurance Card" feature.
-- Run this in the Supabase SQL editor.

create table if not exists public.insurance_cards (
    id uuid primary key default gen_random_uuid(),
    civilian_id uuid not null,
    user_id uuid not null,
    community_id uuid,
    provider text,
    policy_type text,
    policy_number text,
    coverage text,
    expiry_date date,
    created_at timestamptz default now()
);

-- Index for faster lookups by civilian
create index if not exists insurance_cards_civilian_id_idx
    on public.insurance_cards (civilian_id);

alter table public.insurance_cards enable row level security;

-- Allow any logged-in user to read insurance cards
drop policy if exists "insurance_cards_select" on public.insurance_cards;
create policy "insurance_cards_select"
    on public.insurance_cards for select
    to authenticated
    using (true);

-- Users can only create/update/delete their own insurance cards
drop policy if exists "insurance_cards_insert" on public.insurance_cards;
create policy "insurance_cards_insert"
    on public.insurance_cards for insert
    to authenticated
    with check (user_id = auth.uid());

drop policy if exists "insurance_cards_update" on public.insurance_cards;
create policy "insurance_cards_update"
    on public.insurance_cards for update
    to authenticated
    using (user_id = auth.uid());

drop policy if exists "insurance_cards_delete" on public.insurance_cards;
create policy "insurance_cards_delete"
    on public.insurance_cards for delete
    to authenticated
    using (user_id = auth.uid());
