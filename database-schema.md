-- ============================================================
-- PERSONAL STOCK MANAGER + ORDER RUMAH
-- FULL DATABASE SCHEMA CREATION SCRIPT (OWNER + OPERATOR MODEL)
-- ============================================================

begin;

---

-- 0. CUSTOM TYPES / ENUMS

---

create type public.user_role as enum ('OWNER', 'OPERATOR');
create type public.stock_transaction_type as enum ('IN', 'OUT', 'ADJUSTMENT');
create type public.picking_status as enum ('PENDING', 'PARTIAL', 'PICKED');
create type public.verification_result as enum ('MATCH', 'MISMATCH', 'DAMAGED');
create type public.verification_reason as enum ('WRONG_ITEM', 'MISSING_QUANTITY', 'DAMAGED_ITEM', 'OTHER');

---

-- 1. TABLES CREATION

---

-- PROFILES (extends auth.users)
create table public.profiles (
id uuid not null,
name text,
role public.user_role not null default 'OPERATOR'::public.user_role,
owner_id uuid,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
constraint profiles_pkey primary key (id),
constraint profiles_id_fkey foreign key (id) references auth.users(id) on delete cascade,
constraint profiles_owner_id_fkey foreign key (owner_id) references public.profiles(id) on delete cascade,
constraint profiles_role_owner_id_consistency check (
(role = 'OWNER' and owner_id is null)
or
(role = 'OPERATOR' and owner_id is not null and owner_id <> id)
)
);

-- UNITS
create table public.units (
id uuid not null default gen_random_uuid(),
name varchar not null unique,
description text,
created_at timestamptz default now(),
constraint units_pkey primary key (id)
);

-- CATEGORIES
create table public.categories (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
name text not null check (length(trim(both from name)) > 0),
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
constraint categories_pkey primary key (id),
constraint categories_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade
);

-- PRODUCTS
create table public.products (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
category_id uuid not null,
unit_id uuid not null,
name text not null check (length(trim(both from name)) > 0),
sku text,
description text,
image_url text,
purchase_price numeric not null default 0 check (purchase_price >= 0::numeric),
recommended_selling_price numeric not null default 0 check (recommended_selling_price >= 0::numeric),
minimum_stock integer not null default 0 check (minimum_stock >= 0),
current_stock integer not null default 0 check (current_stock >= 0),
is_active boolean not null default true,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
constraint products_pkey primary key (id),
constraint products_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint products_category_id_fkey foreign key (category_id) references public.categories(id) on delete restrict,
constraint products_unit_id_fkey foreign key (unit_id) references public.units(id) on delete restrict
);

-- STOCK TRANSACTIONS
create table public.stock_transactions (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
product_id uuid not null,
type public.stock_transaction_type not null,
quantity integer not null,
adjustment integer not null,
purchase_price numeric check (purchase_price is null or purchase_price >= 0::numeric),
reason text,
note text,
stock_before integer not null,
stock_after integer not null,
created_at timestamptz not null default now(),
constraint stock_transactions_pkey primary key (id),
constraint stock_transactions_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint stock_transactions_product_id_fkey foreign key (product_id) references public.products(id) on delete cascade
);

-- STOCK OPNAMES
create table public.stock_opnames (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
product_id uuid not null,
transaction_id uuid,
system_stock integer not null check (system_stock >= 0),
physical_stock integer not null check (physical_stock >= 0),
difference integer not null,
note text,
created_at timestamptz not null default now(),
constraint stock_opnames_pkey primary key (id),
constraint stock_opnames_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint stock_opnames_product_id_fkey foreign key (product_id) references public.products(id) on delete cascade,
constraint stock_opnames_transaction_id_fkey foreign key (transaction_id) references public.stock_transactions(id) on delete set null
);

-- PRODUCT LOGS
create table public.product_logs (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
product_id uuid,
product_name text not null,
action text not null check (action = any (array['CREATE'::text, 'UPDATE'::text, 'DELETE'::text, 'STOCK_IN'::text, 'STOCK_OUT'::text])),
old_data jsonb,
new_data jsonb,
pic text,
note text,
created_at timestamptz not null default now(),
constraint product_logs_pkey primary key (id),
constraint product_logs_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint product_logs_product_id_fkey foreign key (product_id) references public.products(id) on delete set null
);

-- STORE SETTINGS
create table public.store_settings (
id uuid not null default gen_random_uuid(),
user_id uuid,
store_name varchar not null default 'Warung Saya'::character varying,
address text,
phone_number varchar,
header_footer_note text,
created_at timestamptz default now(),
updated_at timestamptz default now(),
constraint store_settings_pkey primary key (id),
constraint store_settings_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade
);

-- ORDERS
create table public.orders (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_number text not null,
marketplace text,
customer_note text,
status text not null default 'QUEUED'::text,
version integer not null default 1 check (version > 0),
queue_position bigint,
cancel_reason text,
completed_at timestamptz,
cancelled_at timestamptz,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
constraint orders_pkey primary key (id),
constraint orders_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint orders_user_number_key unique (user_id, order_number)
);

-- ORDER ITEMS
create table public.order_items (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_id uuid not null,
product_id uuid not null,
sku_snapshot text not null,
name_snapshot text not null,
variant_snapshot text,
location_snapshot text not null,
photo_snapshot text,
quantity_required integer not null check (quantity_required > 0),
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
constraint order_items_pkey primary key (id),
constraint order_items_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint order_items_order_id_fkey foreign key (order_id) references public.orders(id) on delete cascade,
constraint order_items_product_id_fkey foreign key (product_id) references public.products(id) on delete restrict
);

-- ORDER ITEM PICKINGS
create table public.order_item_pickings (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_item_id uuid not null unique,
quantity_picked integer not null default 0 check (quantity_picked >= 0),
status public.picking_status not null default 'PENDING'::public.picking_status,
picked_at timestamptz,
updated_at timestamptz not null default now(),
constraint order_item_pickings_pkey primary key (id),
constraint order_item_pickings_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint order_item_pickings_order_item_id_fkey foreign key (order_item_id) references public.order_items(id) on delete cascade
);

-- ORDER VERIFICATIONS
create table public.order_verifications (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_id uuid not null,
attempt_number integer not null check (attempt_number > 0),
photo_url text,
result public.verification_result not null,
verified_by uuid not null,
created_at timestamptz not null default now(),
constraint order_verifications_pkey primary key (id),
constraint order_verifications_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint order_verifications_order_id_fkey foreign key (order_id) references public.orders(id) on delete cascade,
constraint order_verifications_verified_by_fkey foreign key (verified_by) references public.profiles(id) on delete restrict,
constraint order_verifications_order_attempt_key unique (order_id, attempt_number)
);

-- ORDER VERIFICATION ITEMS
create table public.order_verification_items (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
verification_id uuid not null,
order_item_id uuid not null,
reason public.verification_reason not null,
note text,
constraint order_verification_items_pkey primary key (id),
constraint order_verification_items_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint order_verification_items_verification_id_fkey foreign key (verification_id) references public.order_verifications(id) on delete cascade,
constraint order_verification_items_order_item_id_fkey foreign key (order_item_id) references public.order_items(id) on delete cascade
);

-- ORDER EVENTS
create table public.order_events (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_id uuid not null,
event_type text not null,
actor_id uuid,
metadata jsonb not null default '{}'::jsonb,
created_at timestamptz not null default now(),
constraint order_events_pkey primary key (id),
constraint order_events_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint order_events_order_id_fkey foreign key (order_id) references public.orders(id) on delete cascade,
constraint order_events_actor_id_fkey foreign key (actor_id) references public.profiles(id) on delete set null
);

-- NOTIFICATIONS
create table public.notifications (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
order_id uuid,
type text not null,
title text not null,
body text not null,
is_read boolean not null default false,
read_at timestamptz,
created_at timestamptz not null default now(),
constraint notifications_pkey primary key (id),
constraint notifications_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade,
constraint notifications_order_id_fkey foreign key (order_id) references public.orders(id) on delete cascade
);

-- USER DEVICES
create table public.user_devices (
id uuid not null default gen_random_uuid(),
user_id uuid not null,
fcm_token text not null unique,
platform text not null,
last_seen_at timestamptz,
created_at timestamptz not null default now(),
constraint user_devices_pkey primary key (id),
constraint user_devices_user_id_fkey foreign key (user_id) references public.profiles(id) on delete cascade
);

---

-- 2. INDEXES CREATION

---

create index profiles_owner_id_idx on public.profiles(owner_id) where owner_id is not null;
create index categories_user_id_idx on public.categories(user_id);
create index products_user_id_idx on public.products(user_id);
create index products_category_id_idx on public.products(category_id);
create index stock_transactions_user_id_idx on public.stock_transactions(user_id);
create index stock_transactions_product_id_idx on public.stock_transactions(product_id);
create index stock_opnames_user_id_idx on public.stock_opnames(user_id);
create index product_logs_user_id_idx on public.product_logs(user_id);
create index store_settings_user_id_idx on public.store_settings(user_id);

create index orders_user_id_idx on public.orders(user_id);
create index orders_user_status_idx on public.orders(user_id, status);
create index orders_queue_idx on public.orders(user_id, queue_position);
create index orders_created_at_idx on public.orders(user_id, created_at);

create index order_items_user_id_idx on public.order_items(user_id);
create index order_items_order_id_idx on public.order_items(order_id);
create index order_items_product_id_idx on public.order_items(product_id);

create index order_item_pickings_user_id_idx on public.order_item_pickings(user_id);
create index order_item_pickings_status_idx on public.order_item_pickings(status);

create index order_verifications_user_id_idx on public.order_verifications(user_id);
create index order_verifications_order_id_idx on public.order_verifications(order_id);
create index order_verifications_verified_by_idx on public.order_verifications(verified_by);

create index order_verification_items_user_id_idx on public.order_verification_items(user_id);
create index order_verification_items_verification_id_idx on public.order_verification_items(verification_id);
create index order_verification_items_order_item_id_idx on public.order_verification_items(order_item_id);

create index order_events_user_id_idx on public.order_events(user_id);
create index order_events_order_id_idx on public.order_events(order_id, created_at);
create index order_events_actor_id_idx on public.order_events(actor_id);
create index order_events_type_idx on public.order_events(event_type);

create index notifications_user_id_idx on public.notifications(user_id, created_at desc);
create index notifications_order_id_idx on public.notifications(order_id);
create index notifications_unread_idx on public.notifications(user_id, is_read);

create index user_devices_user_id_idx on public.user_devices(user_id);
create index user_devices_user_platform_idx on public.user_devices(user_id, platform);

---

-- 3. FUNCTIONS & TRIGGERS

---

-- Helper function for updated_at column
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
new.updated_at = now();
return new;
end;

$$
;

-- Triggers for updated_at
create trigger profiles_set_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger categories_set_updated_at before update on public.categories for each row execute function public.set_updated_at();
create trigger products_set_updated_at before update on public.products for each row execute function public.set_updated_at();
create trigger store_settings_set_updated_at before update on public.store_settings for each row execute function public.set_updated_at();
create trigger orders_set_updated_at before update on public.orders for each row execute function public.set_updated_at();
create trigger order_items_set_updated_at before update on public.order_items for each row execute function public.set_updated_at();
create trigger order_item_pickings_set_updated_at before update on public.order_item_pickings for each row execute function public.set_updated_at();

-- Workspace Helper Functions
create or replace function public.current_workspace_owner_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as
$$

select case
when p.role = 'OWNER' then p.id
when p.role = 'OPERATOR' then p.owner_id
else null
end
from public.profiles p
where p.id = (select auth.uid())
limit 1;

$$
;

create or replace function public.is_workspace_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as
$$

select exists (
select 1
from public.profiles p
where p.id = (select auth.uid())
and p.role = 'OWNER'
and p.owner_id is null
);

$$
;

create or replace function public.is_workspace_member(p_owner_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as
$$

select p_owner_id is not null
and p_owner_id = public.current_workspace_owner_id();

$$
;

-- Permissions for helper functions
revoke all on function public.current_workspace_owner_id() from public;
revoke all on function public.is_workspace_owner() from public;
revoke all on function public.is_workspace_member(uuid) from public;
grant execute on function public.current_workspace_owner_id() to authenticated;
grant execute on function public.is_workspace_owner() to authenticated;
grant execute on function public.is_workspace_member(uuid) to authenticated;


-- ------------------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS) & POLICIES
-- ------------------------------------------------------------

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.units enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.stock_transactions enable row level security;
alter table public.stock_opnames enable row level security;
alter table public.product_logs enable row level security;
alter table public.store_settings enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.order_item_pickings enable row level security;
alter table public.order_verifications enable row level security;
alter table public.order_verification_items enable row level security;
alter table public.order_events enable row level security;
alter table public.notifications enable row level security;
alter table public.user_devices enable row level security;

-- PROFILES
create policy profiles_select_workspace on public.profiles for select to authenticated
using (id = (select auth.uid()) or owner_id = (select auth.uid()));

revoke update on public.profiles from authenticated;
grant update (name) on public.profiles to authenticated;

create policy profiles_update_own_name on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- UNITS (Global readable catalog)
create policy units_select_all on public.units for select to authenticated using (true);

-- CATEGORIES
create policy categories_select_workspace on public.categories for select to authenticated using (public.is_workspace_member(user_id));
create policy categories_owner_insert on public.categories for insert to authenticated with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy categories_owner_update on public.categories for update to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner()) with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy categories_owner_delete on public.categories for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- PRODUCTS
create policy products_select_workspace on public.products for select to authenticated using (public.is_workspace_member(user_id));
create policy products_owner_insert on public.products for insert to authenticated with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy products_owner_update on public.products for update to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner()) with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy products_owner_delete on public.products for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- STOCK TRANSACTIONS (Owner-only ledger)
create policy stock_transactions_owner_select on public.stock_transactions for select to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- STOCK OPNAMES (Owner-only)
create policy stock_opnames_owner_select on public.stock_opnames for select to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- PRODUCT LOGS (Owner-only)
create policy product_logs_owner_select on public.product_logs for select to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- STORE SETTINGS
create policy store_settings_owner_select on public.store_settings for select to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy store_settings_owner_insert on public.store_settings for insert to authenticated with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy store_settings_owner_update on public.store_settings for update to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner()) with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy store_settings_owner_delete on public.store_settings for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- ORDERS
create policy orders_select_workspace on public.orders for select to authenticated using (public.is_workspace_member(user_id));
create policy orders_owner_insert on public.orders for insert to authenticated with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy orders_owner_update on public.orders for update to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner()) with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy orders_owner_delete on public.orders for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- ORDER ITEMS
create policy order_items_select_workspace on public.order_items for select to authenticated using (public.is_workspace_member(user_id));
create policy order_items_owner_insert on public.order_items for insert to authenticated with check (
  user_id = public.current_workspace_owner_id()
  and public.is_workspace_owner()
  and exists (select 1 from public.orders o where o.id = order_id and o.user_id = public.current_workspace_owner_id())
  and exists (select 1 from public.products p where p.id = product_id and p.user_id = public.current_workspace_owner_id())
);
create policy order_items_owner_update on public.order_items for update to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner()) with check (
  user_id = public.current_workspace_owner_id()
  and public.is_workspace_owner()
  and exists (select 1 from public.orders o where o.id = order_id and o.user_id = public.current_workspace_owner_id())
  and exists (select 1 from public.products p where p.id = product_id and p.user_id = public.current_workspace_owner_id())
);
create policy order_items_owner_delete on public.order_items for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- ORDER ITEM PICKINGS
create policy pickings_select_workspace on public.order_item_pickings for select to authenticated using (public.is_workspace_member(user_id));
create policy pickings_operator_or_owner_update on public.order_item_pickings for update to authenticated using (public.is_workspace_member(user_id)) with check (public.is_workspace_member(user_id));
create policy pickings_owner_insert on public.order_item_pickings for insert to authenticated with check (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());
create policy pickings_owner_delete on public.order_item_pickings for delete to authenticated using (user_id = public.current_workspace_owner_id() and public.is_workspace_owner());

-- ORDER VERIFICATIONS
create policy verifications_select_workspace on public.order_verifications for select to authenticated using (public.is_workspace_member(user_id));
create policy verifications_owner_insert on public.order_verifications for insert to authenticated with check (
  user_id = public.current_workspace_owner_id()
  and public.is_workspace_owner()
  and verified_by = (select auth.uid())
  and exists (select 1 from public.orders o where o.id = order_id and o.user_id = public.current_workspace_owner_id())
);

-- ORDER VERIFICATION ITEMS
create policy verification_items_select_workspace on public.order_verification_items for select to authenticated using (public.is_workspace_member(user_id));
create policy verification_items_owner_insert on public.order_verification_items for insert to authenticated with check (
  user_id = public.current_workspace_owner_id()
  and public.is_workspace_owner()
  and exists (select 1 from public.order_verifications ov where ov.id = verification_id and ov.user_id = public.current_workspace_owner_id())
  and exists (select 1 from public.order_items oi where oi.id = order_item_id and oi.user_id = public.current_workspace_owner_id())
);

-- ORDER EVENTS
create policy order_events_select_workspace on public.order_events for select to authenticated using (public.is_workspace_member(user_id));
create policy order_events_insert_workspace on public.order_events for insert to authenticated with check (
  user_id = public.current_workspace_owner_id()
  and public.is_workspace_member(user_id)
  and (actor_id is null or actor_id = (select auth.uid()))
  and exists (select 1 from public.orders o where o.id = order_id and o.user_id = public.current_workspace_owner_id())
);

-- NOTIFICATIONS
create policy notifications_select_own on public.notifications for select to authenticated using (user_id = (select auth.uid()));
create policy notifications_update_own on public.notifications for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy notifications_insert_own on public.notifications for insert to authenticated with check (
  user_id = (select auth.uid())
  and (
    order_id is null
    or exists (select 1 from public.orders o where o.id = order_id and public.is_workspace_member(o.user_id))
  )
);

-- USER DEVICES
create policy user_devices_select_own on public.user_devices for select to authenticated using (user_id = (select auth.uid()));
create policy user_devices_manage_own on public.user_devices for all to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

commit;
$$
