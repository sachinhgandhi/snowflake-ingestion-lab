use role INGESTION_LAB_DEVELOPER_ROLE;
use warehouse INGESTION_LAB_WH;
use database INGESTION_LAB_DB;

create stream if not exists ingestion.raw_customers_stream
on table raw.customers; 

create stream if not exists ingestion.raw_orders_stream
on table raw.orders; 

create stream if not exists ingestion.raw_order_items_stream
on table raw.order_items; 

create stream if not exists ingestion.raw_payments_stream
on table raw.payments; 

create stream if not exists ingestion.raw_web_events_stream
on table raw.web_events; 

create stream if not exists ingestion.raw_support_tickets_stream
on table raw.support_tickets; 

SHOW STREAMS IN SCHEMA INGESTION;