```sql
-- ============================================================
-- PERSONAL STOCK MANAGER
-- SUPABASE DATABASE SCHEMA
-- ============================================================

-- ============================================================
-- EXTENSIONS
-- ============================================================

create extension if not exists pgcrypto;


-- ============================================================
-- ENUMS
-- ============================================================

do $$
begin
    create type stock_transaction_type as enum (
        'IN',
        'OUT',
        'OPNAME'
    );
exception
    when duplicate_object then null;
end $$;


-- ============================================================
-- PROFILES
-- ============================================================

create table if not exists public.profiles (
    id uuid primary key
        references auth.users(id)
        on delete cascade,

    name text,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now()
);


-- ============================================================
-- CATEGORIES
-- ============================================================

create table if not exists public.categories (
    id uuid primary key default gen_random_uuid(),

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    name text not null,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint categories_name_not_empty
        check (length(trim(name)) > 0),

    constraint categories_user_name_unique
        unique (user_id, name)
);


-- ============================================================
-- PRODUCTS
-- ============================================================

create table if not exists public.products (
    id uuid primary key default gen_random_uuid(),

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    category_id uuid not null
        references public.categories(id)
        on delete restrict,

    name text not null,

    sku text,

    unit text,

    description text,

    purchase_price numeric(15,2) not null default 0,

    recommended_selling_price numeric(15,2) not null default 0,

    minimum_stock integer not null default 0,

    current_stock integer not null default 0,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),

    updated_at timestamptz not null default now(),

    constraint products_name_not_empty
        check (length(trim(name)) > 0),

    constraint products_purchase_price_non_negative
        check (purchase_price >= 0),

    constraint products_selling_price_non_negative
        check (recommended_selling_price >= 0),

    constraint products_minimum_stock_non_negative
        check (minimum_stock >= 0),

    constraint products_current_stock_non_negative
        check (current_stock >= 0)
);


-- ============================================================
-- UNIQUE SKU PER USER
-- SKU OPTIONAL
-- ============================================================

create unique index if not exists products_user_sku_unique
on public.products(user_id, sku)
where sku is not null;


-- ============================================================
-- STOCK TRANSACTIONS
-- ============================================================

create table if not exists public.stock_transactions (
    id uuid primary key default gen_random_uuid(),

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    product_id uuid not null
        references public.products(id)
        on delete restrict,

    type stock_transaction_type not null,

    quantity integer not null,

    adjustment integer not null,

    purchase_price numeric(15,2),

    reason text,

    note text,

    stock_before integer not null,

    stock_after integer not null,

    created_at timestamptz not null default now(),

    constraint stock_transaction_quantity_positive
        check (quantity > 0),

    constraint stock_transaction_purchase_price_non_negative
        check (
            purchase_price is null
            or purchase_price >= 0
        )
);


-- ============================================================
-- STOCK OPNAMES
-- ============================================================

create table if not exists public.stock_opnames (
    id uuid primary key default gen_random_uuid(),

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    product_id uuid not null
        references public.products(id)
        on delete restrict,

    transaction_id uuid
        references public.stock_transactions(id)
        on delete restrict,

    system_stock integer not null,

    physical_stock integer not null,

    difference integer not null,

    note text,

    created_at timestamptz not null default now(),

    constraint stock_opname_system_stock_non_negative
        check (system_stock >= 0),

    constraint stock_opname_physical_stock_non_negative
        check (physical_stock >= 0),

    constraint stock_opname_difference_check
        check (difference = physical_stock - system_stock)
);


-- ============================================================
-- PRODUCT LOGS (AUDIT TRAIL)
-- ============================================================

create table if not exists public.product_logs (
    id uuid primary key default gen_random_uuid(),

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    product_id uuid
        references public.products(id)
        on delete set null,

    product_name text not null,

    action text not null,

    old_data jsonb,

    new_data jsonb,

    created_at timestamptz not null default now(),

    constraint product_logs_action_check
        check (action in ('CREATE', 'UPDATE', 'DELETE', 'STOCK_IN', 'STOCK_OUT'))
);


-- ============================================================
-- INDEXES
-- ============================================================

create index if not exists categories_user_id_idx
on public.categories(user_id);


create index if not exists products_user_id_idx
on public.products(user_id);


create index if not exists products_category_id_idx
on public.products(category_id);


create index if not exists products_active_idx
on public.products(user_id, is_active);


create index if not exists products_name_idx
on public.products(user_id, name);


create index if not exists stock_transactions_user_id_idx
on public.stock_transactions(user_id);


create index if not exists stock_transactions_product_id_idx
on public.stock_transactions(product_id);


create index if not exists stock_transactions_created_at_idx
on public.stock_transactions(created_at desc);


create index if not exists stock_opnames_user_id_idx
on public.stock_opnames(user_id);


create index if not exists stock_opnames_product_id_idx
on public.stock_opnames(product_id);


create index if not exists product_logs_user_id_idx
on public.product_logs(user_id);


create index if not exists product_logs_product_id_idx
on public.product_logs(product_id);


create index if not exists product_logs_created_at_idx
on public.product_logs(created_at desc);


-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;


drop trigger if exists profiles_set_updated_at
on public.profiles;

create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();


drop trigger if exists categories_set_updated_at
on public.categories;

create trigger categories_set_updated_at
before update on public.categories
for each row
execute function public.set_updated_at();


drop trigger if exists products_set_updated_at
on public.products;

create trigger products_set_updated_at
before update on public.products
for each row
execute function public.set_updated_at();


-- ============================================================
-- AUTO CREATE PROFILE AFTER AUTH USER CREATED
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (
        id,
        name
    )
    values (
        new.id,
        coalesce(new.raw_user_meta_data ->> 'name', '')
    );

    return new;
end;
$$;


drop trigger if exists on_auth_user_created
on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();


-- ============================================================
-- PRODUCT AUDIT LOG TRIGGER
-- ============================================================

create or replace function public.handle_product_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    v_action text;
begin
    if (TG_OP = 'INSERT') then
        insert into public.product_logs (
            user_id,
            product_id,
            product_name,
            action,
            old_data,
            new_data
        ) values (
            NEW.user_id,
            NEW.id,
            NEW.name,
            'CREATE',
            null,
            to_jsonb(NEW)
        );
        return NEW;

    elsif (TG_OP = 'UPDATE') then
        -- Deteksi otomatis jenis perubahan stok vs editan data produk
        if (OLD.current_stock < NEW.current_stock and OLD.name = NEW.name and OLD.purchase_price = NEW.purchase_price) then
            v_action := 'STOCK_IN';
        elsif (OLD.current_stock > NEW.current_stock and OLD.name = NEW.name and OLD.purchase_price = NEW.purchase_price) then
            v_action := 'STOCK_OUT';
        else
            v_action := 'UPDATE';
        end if;

        insert into public.product_logs (
            user_id,
            product_id,
            product_name,
            action,
            old_data,
            new_data
        ) values (
            NEW.user_id,
            NEW.id,
            NEW.name,
            v_action,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
        return NEW;

    elsif (TG_OP = 'DELETE') then
        insert into public.product_logs (
            user_id,
            product_id,
            product_name,
            action,
            old_data,
            new_data
        ) values (
            OLD.user_id,
            OLD.id,
            OLD.name,
            'DELETE',
            to_jsonb(OLD),
            null
        );
        return OLD;
    end if;

    return null;
end;
$$;


drop trigger if exists on_product_change_audit_log
on public.products;

create trigger on_product_change_audit_log
after insert or update or delete on public.products
for each row
execute function public.handle_product_audit_log();


-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.stock_transactions enable row level security;
alter table public.stock_opnames enable row level security;
alter table public.product_logs enable row level security;


-- ============================================================
-- PROFILES POLICIES
-- ============================================================

drop policy if exists "Users can view own profile"
on public.profiles;

create policy "Users can view own profile"
on public.profiles
for select
using (
    auth.uid() = id
);


drop policy if exists "Users can update own profile"
on public.profiles;

create policy "Users can update own profile"
on public.profiles
for update
using (
    auth.uid() = id
)
with check (
    auth.uid() = id
);


-- ============================================================
-- CATEGORY POLICIES
-- ============================================================

drop policy if exists "Users can view own categories"
on public.categories;

create policy "Users can view own categories"
on public.categories
for select
using (
    auth.uid() = user_id
);


drop policy if exists "Users can insert own categories"
on public.categories;

create policy "Users can insert own categories"
on public.categories
for insert
with check (
    auth.uid() = user_id
);


drop policy if exists "Users can update own categories"
on public.categories;

create policy "Users can update own categories"
on public.categories
for update
using (
    auth.uid() = user_id
)
with check (
    auth.uid() = user_id
);


drop policy if exists "Users can delete own categories"
on public.categories;

create policy "Users can delete own categories"
on public.categories
for delete
using (
    auth.uid() = user_id
);


-- ============================================================
-- PRODUCT POLICIES
-- ============================================================

drop policy if exists "Users can view own products"
on public.products;

create policy "Users can view own products"
on public.products
for select
to authenticated
using (
    auth.uid() = user_id
);


drop policy if exists "Users can insert own products"
on public.products;

create policy "Users can insert own products"
on public.products
for insert
to authenticated
with check (
    auth.uid() = user_id
);


drop policy if exists "Users can update own products"
on public.products;

create policy "Users can update own products"
on public.products
for update
to authenticated
using (
    auth.uid() = user_id
)
with check (
    auth.uid() = user_id
);


drop policy if exists "Users can delete own products"
on public.products;

create policy "Users can delete own products"
on public.products
for delete
to authenticated
using (
    auth.uid() = user_id
);


-- ============================================================
-- TRANSACTION POLICIES
-- ============================================================

create policy "Users can view own stock transactions"
on public.stock_transactions
for select
using (
    auth.uid() = user_id
);


-- IMPORTANT:
-- Direct INSERT/UPDATE/DELETE from client should NOT be used
-- for stock transactions.
-- Stock mutations are handled through RPC functions below.


-- ============================================================
-- OPNAME POLICIES
-- ============================================================

create policy "Users can view own stock opnames"
on public.stock_opnames
for select
using (
    auth.uid() = user_id
);


-- ============================================================
-- PRODUCT LOGS POLICIES
-- ============================================================

drop policy if exists "Users can view own product logs"
on public.product_logs;

create policy "Users can view own product logs"
on public.product_logs
for select
to authenticated
using (
    auth.uid() = user_id
);


-- ============================================================
-- STOCK IN RPC
-- ============================================================

create or replace function public.stock_in(
    p_product_id uuid,
    p_quantity integer,
    p_purchase_price numeric,
    p_note text default null
)
returns public.stock_transactions
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_user_id uuid;
    v_product public.products;
    v_transaction public.stock_transactions;
begin

    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication required';
    end if;

    if p_quantity <= 0 then
        raise exception 'Quantity must be greater than zero';
    end if;

    if p_purchase_price < 0 then
        raise exception 'Purchase price cannot be negative';
    end if;

    select *
    into v_product
    from public.products
    where id = p_product_id
      and user_id = v_user_id
      and is_active = true
    for update;

    if not found then
        raise exception 'Product not found or inactive';
    end if;

    insert into public.stock_transactions (
        user_id,
        product_id,
        type,
        quantity,
        adjustment,
        purchase_price,
        reason,
        note,
        stock_before,
        stock_after
    )
    values (
        v_user_id,
        p_product_id,
        'IN',
        p_quantity,
        p_quantity,
        p_purchase_price,
        'Stock In',
        p_note,
        v_product.current_stock,
        v_product.current_stock + p_quantity
    )
    returning *
    into v_transaction;

    update public.products
    set
        current_stock = current_stock + p_quantity,
        purchase_price = p_purchase_price,
        updated_at = now()
    where id = p_product_id
      and user_id = v_user_id;

    return v_transaction;
end;
$$;


-- ============================================================
-- STOCK OUT RPC
-- ============================================================

create or replace function public.stock_out(
    p_product_id uuid,
    p_quantity integer,
    p_reason text,
    p_note text default null
)
returns public.stock_transactions
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_user_id uuid;
    v_product public.products;
    v_transaction public.stock_transactions;
begin

    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication required';
    end if;

    if p_quantity <= 0 then
        raise exception 'Quantity must be greater than zero';
    end if;

    select *
    into v_product
    from public.products
    where id = p_product_id
      and user_id = v_user_id
      and is_active = true
    for update;

    if not found then
        raise exception 'Product not found or inactive';
    end if;

    if v_product.current_stock < p_quantity then
        raise exception
            'Insufficient stock. Available: %, requested: %',
            v_product.current_stock,
            p_quantity;
    end if;

    insert into public.stock_transactions (
        user_id,
        product_id,
        type,
        quantity,
        adjustment,
        purchase_price,
        reason,
        note,
        stock_before,
        stock_after
    )
    values (
        v_user_id,
        p_product_id,
        'OUT',
        p_quantity,
        -p_quantity,
        v_product.purchase_price,
        p_reason,
        p_note,
        v_product.current_stock,
        v_product.current_stock - p_quantity
    )
    returning *
    into v_transaction;

    update public.products
    set
        current_stock = current_stock - p_quantity,
        updated_at = now()
    where id = p_product_id
      and user_id = v_user_id;

    return v_transaction;
end;
$$;


-- ============================================================
-- STOCK OPNAME RPC
-- ============================================================

create or replace function public.stock_opname(
    p_product_id uuid,
    p_physical_stock integer,
    p_note text default null
)
returns public.stock_opnames
language plpgsql
security invoker
set search_path = public
as $$
declare
    v_user_id uuid;
    v_product public.products;
    v_difference integer;
    v_transaction public.stock_transactions;
    v_opname public.stock_opnames;
begin

    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'Authentication required';
    end if;

    if p_physical_stock < 0 then
        raise exception 'Physical stock cannot be negative';
    end if;

    select *
    into v_product
    from public.products
    where id = p_product_id
      and user_id = v_user_id
      and is_active = true
    for update;

    if not found then
        raise exception 'Product not found or inactive';
    end if;

    v_difference :=
        p_physical_stock - v_product.current_stock;

    -- Create stock transaction only when there is a difference.
    if v_difference <> 0 then

        insert into public.stock_transactions (
            user_id,
            product_id,
            type,
            quantity,
            adjustment,
            purchase_price,
            reason,
            note,
            stock_before,
            stock_after
        )
        values (
            v_user_id,
            p_product_id,
            'OPNAME',
            abs(v_difference),
            v_difference,
            v_product.purchase_price,
            'Stock Opname',
            p_note,
            v_product.current_stock,
            p_physical_stock
        )
        returning *
        into v_transaction;

        update public.products
        set
            current_stock = p_physical_stock,
            updated_at = now()
        where id = p_product_id
          and user_id = v_user_id;

    else

        -- No stock adjustment.
        insert into public.stock_transactions (
            user_id,
            product_id,
            type,
            quantity,
            adjustment,
            purchase_price,
            reason,
            note,
            stock_before,
            stock_after
        )
        values (
            v_user_id,
            p_product_id,
            'OPNAME',
            0,
            0,
            v_product.purchase_price,
            'Stock Opname',
            p_note,
            v_product.current_stock,
            p_physical_stock
        )
        returning *
        into v_transaction;

    end if;

    insert into public.stock_opnames (
        user_id,
        product_id,
        transaction_id,
        system_stock,
        physical_stock,
        difference,
        note
    )
    values (
        v_user_id,
        p_product_id,
        v_transaction.id,
        v_product.current_stock,
        p_physical_stock,
        v_difference,
        p_note
    )
    returning *
    into v_opname;

    return v_opname;
end;
$$;


-- ============================================================
-- TABLE PERMISSIONS
-- ============================================================

grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage, select on all sequences in schema public to authenticated;


-- ============================================================
-- RPC PERMISSIONS
-- ============================================================

revoke all
on function public.stock_in(uuid, integer, numeric, text)
from public;

grant execute
on function public.stock_in(uuid, integer, numeric, text)
to authenticated;


revoke all
on function public.stock_out(uuid, integer, text, text)
from public;

grant execute
on function public.stock_out(uuid, integer, text, text)
to authenticated;


revoke all
on function public.stock_opname(uuid, integer, text)
from public;

grant execute
on function public.stock_opname(uuid, integer, text)
to authenticated;


-- ============================================================
-- REALTIME
-- ============================================================

-- Add tables to Supabase Realtime publication.
-- If a table is already included, PostgreSQL may report that
-- it is already a member of the publication.

do $$
begin
    alter publication supabase_realtime
        add table public.products;
exception
    when duplicate_object then null;
end $$;


do $$
begin
    alter publication supabase_realtime
        add table public.stock_transactions;
exception
    when duplicate_object then null;
end $$;


-- ============================================================
-- HELPFUL VIEW: LOW STOCK
-- ============================================================

create or replace view public.low_stock_products
with (security_invoker = true)
as
select
    p.id,
    p.user_id,
    p.category_id,
    p.name,
    p.sku,
    p.purchase_price,
    p.recommended_selling_price,
    p.minimum_stock,
    p.current_stock,
    p.is_active,
    p.created_at,
    p.updated_at
from public.products p
where
    p.is_active = true
    and p.current_stock <= p.minimum_stock;


-- ============================================================
-- HELPFUL VIEW: INVENTORY SUMMARY
-- ============================================================

create or replace view public.inventory_summary
with (security_invoker = true)
as
select
    p.user_id,

    count(*)::integer as total_products,

    coalesce(
        sum(p.current_stock),
        0
    )::bigint as total_items,

    coalesce(
        sum(
            p.current_stock * p.purchase_price
        ),
        0
    )::numeric(15,2) as inventory_value

from public.products p

where p.is_active = true

group by p.user_id;
```