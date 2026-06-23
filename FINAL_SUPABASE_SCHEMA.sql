-- ============================================================
-- Forever Living - Complete Supabase Schema & Full Data Seed
-- Run this ENTIRE script in your Supabase SQL Editor
-- (Dashboard → SQL Editor → New Query → paste → Run)
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ============================================================
-- STEP 1: Drop existing tables (clean slate, safe re-run)
-- ============================================================
drop table if exists public.order_items       cascade;
drop table if exists public.orders            cascade;
drop table if exists public.cart_items        cascade;
drop table if exists public.carts             cascade;
drop table if exists public.career_applications cascade;
drop table if exists public.chat_faqs         cascade;
drop table if exists public.products          cascade;
drop table if exists public.users             cascade;

-- ============================================================
-- STEP 2: Create Tables
-- ============================================================

-- Users
create table public.users (
  id           text primary key,
  name         text not null,
  email        text not null unique,
  password_hash text not null,
  role         text not null default 'customer',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Products
create table public.products (
  id          text primary key,
  name        text not null,
  description text not null default '',
  price       numeric(12,2) not null,
  currency    text not null default 'INR',
  category    text not null default 'General',
  trend       text not null default 'stable' check (trend in ('up','down','stable')),
  image       text not null default '',
  in_stock    boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Carts (one per user)
create table public.carts (
  id         text primary key,
  user_id    text not null references public.users(id) on delete cascade unique,
  updated_at timestamptz not null default now()
);

-- Cart Items
create table public.cart_items (
  id         text primary key,
  cart_id    text not null references public.carts(id) on delete cascade,
  product_id text not null references public.products(id) on delete cascade,
  quantity   int  not null default 1 check (quantity > 0),
  unique (cart_id, product_id)
);

-- Orders
create table public.orders (
  id               text primary key,
  user_id          text not null references public.users(id),
  status           text not null default 'placed'
                     check (status in ('placed','processing','shipped','delivered','done','cancelled')),
  payment_method   text not null default 'COD',
  shipping_address text not null default 'None',
  subtotal         numeric(12,2) not null default 0,
  tax              numeric(12,2) not null default 0,
  shipping         numeric(12,2) not null default 0,
  total            numeric(12,2) not null default 0,
  currency         text not null default 'INR',
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Order Items
create table public.order_items (
  id         text primary key,
  order_id   text not null references public.orders(id) on delete cascade,
  product_id text not null references public.products(id) on delete restrict,
  name       text not null,
  price      numeric(12,2) not null,
  currency   text not null default 'INR',
  quantity   int  not null check (quantity > 0)
);

-- Career Applications
create table public.career_applications (
  id         text primary key,
  user_id    text references public.users(id) on delete set null,
  name       text not null,
  email      text not null,
  phone      text not null default '',
  interest   text not null default '',
  experience text not null default '',
  message    text not null default '',
  status     text not null default 'pending'
               check (status in ('pending','reviewing','selected','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Chat FAQs
create table public.chat_faqs (
  id         text primary key,
  question   text not null,
  answer     text not null,
  keywords   text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================
-- STEP 3: Indexes (for performance)
-- ============================================================
create index idx_users_email          on public.users (email);
create index idx_products_category    on public.products (category);
create index idx_products_trend       on public.products (trend);
create index idx_products_in_stock    on public.products (in_stock);
create index idx_cart_items_cart_id   on public.cart_items (cart_id);
create index idx_cart_items_product   on public.cart_items (product_id);
create index idx_orders_user_id       on public.orders (user_id);
create index idx_orders_status        on public.orders (status);
create index idx_order_items_order    on public.order_items (order_id);
create index idx_careers_user_id      on public.career_applications (user_id);
create index idx_careers_status       on public.career_applications (status);

-- ============================================================
-- STEP 4: updated_at auto-trigger
-- ============================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_users_updated
  before update on public.users
  for each row execute function public.set_updated_at();

create trigger trg_products_updated
  before update on public.products
  for each row execute function public.set_updated_at();

create trigger trg_orders_updated
  before update on public.orders
  for each row execute function public.set_updated_at();

create trigger trg_careers_updated
  before update on public.career_applications
  for each row execute function public.set_updated_at();

create trigger trg_chat_faqs_updated
  before update on public.chat_faqs
  for each row execute function public.set_updated_at();

create trigger trg_carts_updated
  before update on public.carts
  for each row execute function public.set_updated_at();

-- ============================================================
-- STEP 5: Row Level Security (RLS)
-- ============================================================
-- Enable RLS on all tables
alter table public.users                enable row level security;
alter table public.products             enable row level security;
alter table public.carts                enable row level security;
alter table public.cart_items           enable row level security;
alter table public.orders               enable row level security;
alter table public.order_items          enable row level security;
alter table public.career_applications  enable row level security;
alter table public.chat_faqs            enable row level security;

-- Full access for the anon (service) key used by the backend
-- The backend uses the anon key as a server-side key, so we allow all.
create policy "anon_all_users"           on public.users                 for all using (true) with check (true);
create policy "anon_all_products"        on public.products               for all using (true) with check (true);
create policy "anon_all_carts"           on public.carts                  for all using (true) with check (true);
create policy "anon_all_cart_items"      on public.cart_items             for all using (true) with check (true);
create policy "anon_all_orders"          on public.orders                 for all using (true) with check (true);
create policy "anon_all_order_items"     on public.order_items            for all using (true) with check (true);
create policy "anon_all_careers"         on public.career_applications    for all using (true) with check (true);
create policy "anon_all_chat_faqs"       on public.chat_faqs              for all using (true) with check (true);

-- ============================================================
-- STEP 6: Seed Data (full sync from current db.json)
-- ============================================================

-- ── Admin User ──────────────────────────────────────────────
insert into public.users (id, name, email, password_hash, role, created_at, updated_at)
values
  (
    'usr_05d81c9d9e9f',
    'Forever Admin',
    'admin@forever.com',
    '$2b$10$QExy17FSC0Yji6N2W4pau.l.Fdwa1ag0KtEV0zdMht9yjDIF87GWq',
    'admin',
    '2026-03-23T04:19:24.846Z',
    '2026-03-23T04:19:24.846Z'
  )
on conflict (id) do update
  set name          = excluded.name,
      email         = excluded.email,
      password_hash = excluded.password_hash,
      role          = excluded.role,
      updated_at    = excluded.updated_at;

-- ── Products (all 12 from db.json) ──────────────────────────
insert into public.products
  (id, name, description, price, currency, category, trend, image, in_stock, created_at, updated_at)
values
  (
    'prd_avocado_soap',
    'Avocado Face & Body Soap',
    'Gentle cleansing soap with moisturizing avocado extracts.',
    299, 'INR', 'Personal Care', 'up',
    'images/Avocado Face & Body Soap.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_bee_honey',
    'Forever Bee Honey',
    'Natural honey for daily nutrition and energy support.',
    499, 'INR', 'Nutrition', 'up',
    'images/Forever Bee Honey.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_deep_moisturizer',
    'Deep Moisturizing Cream',
    'Hydrating cream for dry skin and all-weather protection.',
    799, 'INR', 'Skin Care', 'down',
    'images/Deep Moisturizing Cream.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_toothgel',
    'Forever Bright Toothgel',
    'Aloe-based toothgel for fresh breath and oral care.',
    349, 'INR', 'Personal Care', 'stable',
    'images/Forever Bright Toothgel.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_cooling_lotion',
    'Aloe Cooling Lotion',
    'Cooling lotion to soothe skin post sun exposure.',
    599, 'INR', 'Skin Care', 'down',
    'images/Aloe Cooling Lotion.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_body_wash',
    'Aloe Body Wash',
    'Refreshing aloe body wash for daily gentle cleansing.',
    449, 'INR', 'Personal Care', 'up',
    'images/Aloe Body Wash.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_aloe_vera_gel',
    'Forever Aloe Vera Gel',
    'Inner leaf aloe vera drink that supports daily wellness and digestion.',
    1899, 'INR', 'Nutrition', 'up',
    'https://cdn.foreverliving.com/content/products/images/forever_aloe_vera_gel__pd_main_512_X_512_1730754836654.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_freedom',
    'Forever Freedom',
    'Aloe-based drink with glucosamine and chondroitin for active lifestyle support.',
    2899, 'INR', 'Nutrition', 'up',
    'https://cdn.foreverliving.com/content/products/images/forever_freedom__pd_main_512_X_512_1611251005788.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_bee_propolis',
    'Forever Bee Propolis',
    'Bee propolis chewable supplement to support daily immune wellness.',
    2399, 'INR', 'Nutrition', 'stable',
    'https://cdn.foreverliving.com/content/products/images/forever_bee_propolis__pd_main_512_X_512_1649278429705.jpg',
    true,
    '2026-03-23T04:19:24.846Z', '2026-03-23T04:19:24.846Z'
  ),
  (
    'prd_royal_jelly',
    'Forever Royal Jelly',
    'Royal jelly dietary supplement for nutritional support and vitality.',
    2599, 'INR', 'Nutrition', 'stable',
    'https://cdn.foreverliving.com/content/products/images/forever_royal_jelly__pd_category_256_X_256_1649278724703.jpg',
    true,
    '2026-03-23T08:46:14.949Z', '2026-03-23T08:46:14.949Z'
  ),
  (
    'prd_bee_pollen',
    'Forever Bee Pollen',
    'Natural bee pollen supplement for nutrition and energy support.',
    1499, 'INR', 'Nutrition', 'up',
    'https://cdn.foreverliving.com/content/products/images/forever_bee_pollen__pd_main_512_X_512_1649278499431.jpg',
    true,
    '2026-03-23T08:46:17.517Z', '2026-03-23T08:46:17.517Z'
  ),
  (
    'prd_garcinia_plus',
    'Forever Garcinia Plus',
    'Garcinia and chromium based supplement for weight-management routines.',
    2499, 'INR', 'Nutrition', 'up',
    'https://cdn.foreverliving.com/content/products/images/forever_garcinia_plus__pd_main_512_X_512_1611596473456.jpg',
    true,
    '2026-03-23T08:46:21.543Z', '2026-03-23T08:46:21.543Z'
  )
on conflict (id) do update
  set name        = excluded.name,
      description = excluded.description,
      price       = excluded.price,
      currency    = excluded.currency,
      category    = excluded.category,
      trend       = excluded.trend,
      image       = excluded.image,
      in_stock    = excluded.in_stock,
      updated_at  = excluded.updated_at;

-- ── Chat FAQs ────────────────────────────────────────────────
insert into public.chat_faqs (id, question, answer, keywords, created_at, updated_at)
values
  ('faq_join',       'How to join?',             'You can join Forever by contacting us through the support team.', 'join,register,sign up', now(), now()),
  ('faq_investment', 'Is there any investment?', 'No big investment is required to get started.',                  'investment,money,cost',  now(), now()),
  ('faq_orders',     'How can I track my order?','Go to My Orders in your account to see current order status.',   'order,track,status',     now(), now())
on conflict (id) do update
  set question   = excluded.question,
      answer     = excluded.answer,
      keywords   = excluded.keywords,
      updated_at = excluded.updated_at;

-- ── Career Application (from db.json) ────────────────────────
insert into public.career_applications
  (id, user_id, name, email, phone, interest, experience, message, status, created_at, updated_at)
values
  (
    'car_88cf9efce8c2',
    'usr_05d81c9d9e9f',
    'Thakor Aryansinh',
    'thakoraryan2804@gmail.com',
    '07861948015',
    'marketing',
    '1 year',
    'ntg',
    'pending',
    '2026-03-23T08:20:12.472Z',
    '2026-03-23T08:20:12.472Z'
  )
on conflict (id) do update
  set name       = excluded.name,
      email      = excluded.email,
      phone      = excluded.phone,
      interest   = excluded.interest,
      experience = excluded.experience,
      message    = excluded.message,
      status     = excluded.status,
      updated_at = excluded.updated_at;

-- ============================================================
-- Done! All tables, indexes, triggers, RLS policies, and data
-- are now fully set up in Supabase.
-- ============================================================
