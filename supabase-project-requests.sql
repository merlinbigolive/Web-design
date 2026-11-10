-- Northstar Digital: project request table
-- Run this in Supabase SQL Editor after reviewing your existing project.
create table if not exists public.project_requests (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references auth.users(id) on delete cascade,
  contact_name text not null,
  contact_email text not null,
  country text not null,
  phone text not null,
  project_type text not null,
  features text[] not null default '{}',
  budget text not null,
  timeline text not null default 'Flexible',
  description text not null,
  reference_url text,
  status text not null default 'new'
    check (status in ('new','reviewing','quoted','approved','in_progress','review','delivered','cancelled')),
  created_at timestamptz not null default now()
);

alter table public.project_requests enable row level security;

drop policy if exists "Clients can create their own project requests" on public.project_requests;
create policy "Clients can create their own project requests"
on public.project_requests for insert to authenticated
with check (auth.uid() = client_id);

drop policy if exists "Clients can view their own project requests" on public.project_requests;
create policy "Clients can view their own project requests"
on public.project_requests for select to authenticated
using (auth.uid() = client_id);

-- Important: Do not add a public SELECT policy. Admin access should be granted
-- through a protected server-side/admin workflow, not by exposing all requests
-- to every signed-in client.
