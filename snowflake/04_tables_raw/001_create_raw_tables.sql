Use Role INGESTION_LAB_DEVELOPER_ROLE;
Use Database INGESTION_LAB_DB;

create table if not exists raw.customers (
    customer_id text,
    first_name text,
    last_name text,
    email text,
    phone text,
    city text,
    state_name text,
    country text,
    created_at timestamp_ntz,
    updated_at timestamp_ntz,
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.customers add column batch_id text;


create table if not exists raw.orders (
    order_id text,
    customer_id text,
    order_status text,
    order_date timestamp_ntz,
    currency text,
    order_amount number(18,2),
    payment_status text,
    shipping_city text,
    shipping_country text,
    updated_at timestamp_ntz,
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.orders add column batch_id text;


create table if not exists raw.order_items (
    order_item_id text,
    order_id text,
    product_id text,
    product_name text,
    category text,
    quantity number,
    unit_price number(18,2),
    line_amount number(18,2),
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.order_items add column batch_id text;


create table if not exists raw.payments (
    payment_id text,
    order_id text,
    payment_method text,
    payment_status text,
    payment_amount number,
    payment_timestamp timestamp_ntz,
    transaction_reference text,
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.payments add column batch_id text;


create table if not exists raw.web_events (
    v1 variant,
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.web_events add column batch_id text;


create table if not exists raw.support_tickets (
    v1 variant,
    source_file_name text,
    source_row_number number,
    load_ts timestamp_ltz
);

Alter table raw.support_tickets add column batch_id text;

