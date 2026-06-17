USE ROLE INGESTION_LAB_DEVELOPER_ROLE;
use warehouse INGESTION_LAB_WH;
USE DATABASE INGESTION_LAB_DB;

CREATE TABLE IF NOT EXISTS LANDING.CUSTOMERS (
    customer_id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    state_name TEXT,
    country TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS LANDING.ORDERS (
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_date TIMESTAMP_NTZ,
    currency TEXT,
    order_amount NUMBER(18,2),
    payment_status TEXT,
    shipping_city TEXT,
    shipping_country TEXT,
    updated_at TIMESTAMP_NTZ,
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS LANDING.ORDER_ITEMS (
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    quantity NUMBER,
    unit_price NUMBER(18,2),
    line_amount NUMBER(18,2),
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS LANDING.PAYMENTS (
    payment_id TEXT,
    order_id TEXT,
    payment_method TEXT,
    payment_status TEXT,
    payment_amount NUMBER(18,2),
    payment_timestamp TIMESTAMP_NTZ,
    transaction_reference TEXT,
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS LANDING.WEB_EVENTS (
    v1 VARIANT,
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS LANDING.SUPPORT_TICKETS (
    v1 VARIANT,
    source_file_name TEXT,
    source_row_number NUMBER,
    batch_id TEXT,
    load_ts TIMESTAMP_LTZ,
    landing_ts TIMESTAMP_LTZ
);

SHOW TABLES IN SCHEMA LANDING;