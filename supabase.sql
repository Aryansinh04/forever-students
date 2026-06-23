-- ============================================================
-- Supabase (PostgreSQL) Schema
-- Run in Supabase SQL Editor
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- Users (basic details)
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null unique,
  phone text,
  address text,
  created_at timestamptz not null default now()
);

-- Products (name + quantity)
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  quantity int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Optional: keep updated_at current
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

-- Suggested indexes
create index if not exists idx_users_email on public.users (email);
create index if not exists idx_products_name on public.products (name);
