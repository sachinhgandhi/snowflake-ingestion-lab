Use Role INGESTION_LAB_DEVELOPER_ROLE;
use warehouse INGESTION_LAB_WH;
Use Database INGESTION_LAB_DB;

SET batch_id = (SELECT UUID_STRING());
SET load_started_at = (SELECT CURRENT_TIMESTAMP());

INSERT INTO AUDIT.LOAD_BATCH (
    batch_id,
    batch_name,
    source_system,
    load_method,
    batch_status,
    started_at,
    total_files_expected,
    created_by
)
SELECT
    $batch_id,
    'Data load from source',
    'AWS_S3',
    'COPY_INTO',
    'STARTED',
    $load_started_at,
    1,
    CURRENT_USER();

-----------------------------------------------------------------------------------------------------------------------
-- Customer Load - Start
-----------------------------------------------------------------------------------------------------------------------

Copy into raw.customers(
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    state_name,
    country,
    created_at,
    updated_at,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts
)
from (
    Select 
        $1::text, -- customer_id,
        $2::text, -- first_name,
        $3::text, -- last_name,
        $4::text, -- email,
        $5::text, -- phone,
        $6::text, -- city,
        $7::text, -- state,
        $8::text, -- country,
        $9::timestamp_ntz, -- created_at,
        $10::timestamp_ntz, -- updated_at,
        metadata$filename::text,
        metadata$file_row_number::number,
        $batch_id::text,
        current_timestamp()
    from @ingestion.STG_S3_INGESTION_LAB/incoming/structured/customers/
    -- (pattern => '.*customers_.*\.csv')
)
File_Format = (Format_Name = ingestion.ff_csv_standard)
pattern = '.*customers_.*[.]csv'
on_error = abort_statement
Force = True;

SET copy_query_id = (SELECT LAST_QUERY_ID());

CREATE OR REPLACE TEMP TABLE TMP_CUSTOMER_COPY_RESULT AS
SELECT *
FROM TABLE(RESULT_SCAN($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.CUSTOMERS',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/structured/customers/',
    'CSV',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM TMP_CUSTOMER_COPY_RESULT;

-----------------------------------------------------------------------------------------------------------------------
-- Customer Load - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Order Load - Start
-----------------------------------------------------------------------------------------------------------------------

Copy into raw.orders (
    order_id,
    customer_id,
    order_status,
    order_date,
    currency,
    order_amount,
    payment_status,
    shipping_city,
    shipping_country,
    updated_at,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts
)
from (
    Select
        $1::text,
        $2::text,
        $3::text,
        $4::timestamp_ntz,
        $5::text,
        $6::number(18,2),
        $7::text,
        $8::text,
        $9::text,
        $10::timestamp_ntz,
        metadata$filename::text,
        metadata$file_row_number,
        $batch_id::text,
        current_timestamp()
    from @ingestion.STG_S3_INGESTION_LAB/incoming/structured/orders/
)
File_Format = (Format_Name = ingestion.ff_csv_standard)
Pattern = '.*orders_.*[.]csv'
On_Error = abort_statement
Force = True;

set copy_query_id = (select last_query_id());

create or replace temp table tmp_order_copy_result as
Select * from table (result_scan($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.Orders',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/structured/orders/',
    'CSV',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM tmp_order_copy_result;

-----------------------------------------------------------------------------------------------------------------------
-- Order Load - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Order Items Load - Start
-----------------------------------------------------------------------------------------------------------------------

Copy into raw.order_items (
    order_item_id,
    order_id,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    line_amount,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts
)
from (
    Select
        $1::text, -- order_item_id,
        $2::text, -- order_id,
        $3::text, -- product_id,
        $4::text, -- product_name,
        $5::text, -- category,
        $6::number, -- quantity,
        $7::number(18,2), -- unit_price,
        $8::number(18,2), -- line_amount,
        metadata$filename::text, -- source_file_name,
        metadata$file_row_number::number, -- source_row_number,
        $batch_id::text, -- batch_id,
        current_timestamp() -- load_ts timestamp_ltz
    from @ingestion.STG_S3_INGESTION_LAB/incoming/structured/order_items/
)
File_Format = (Format_Name = ingestion.ff_csv_standard)
Pattern = '.*order_items_.*[.]csv'
on_error = abort_statement
Force = true;

set copy_query_id = (Select last_query_id());

create or replace temp table tmp_order_items_copy_result as
Select * from table(result_scan($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.Order_items',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/structured/order_items/',
    'CSV',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM tmp_order_items_copy_result;


-----------------------------------------------------------------------------------------------------------------------
-- Order Items Load - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Payments Load - Start
-----------------------------------------------------------------------------------------------------------------------

Copy into raw.payments (
    payment_id,
    order_id,
    payment_method,
    payment_status,
    payment_amount,
    payment_timestamp,
    transaction_reference,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts   
)
from (
    Select
        $1::text, -- payment_id,
        $2::text, -- order_id,
        $3::text, -- payment_method,
        $4::text, -- payment_status,
        $5::number(18,2), -- payment_amount,
        $6::timestamp_ntz, -- payment_timestamp,
        $7::text, -- transaction_reference,
        metadata$filename::text, -- source_file_name,
        metadata$file_row_number::number, -- source_row_number,
        $batch_id::text, -- batch_id,
        current_timestamp() -- load_ts
    from @ingestion.STG_S3_INGESTION_LAB/incoming/structured/payments/
)
file_format = (format_name = ingestion.ff_csv_standard)
pattern = '.*payments_.*[.]csv'
on_error = abort_statement
Force = True;

set copy_query_id = (select last_query_id());

create or replace temp table tmp_payments_copy_result as
Select * from table (result_scan($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.payments',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/structured/payments/',
    'CSV',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM tmp_payments_copy_result;

-----------------------------------------------------------------------------------------------------------------------
-- Payments Load - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Web Events Load - Start
-----------------------------------------------------------------------------------------------------------------------

copy into raw.web_events (
    v1,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts
)
from (
    Select
        $1::variant, -- v1,
        metadata$filename::text, -- source_file_name,
        metadata$file_row_number::number, -- source_row_number,
        $batch_id::text, -- batch_id,
        current_timestamp() -- load_ts
    from @ingestion.STG_S3_INGESTION_LAB/incoming/semi_structured/web_events/
)
file_format = (format_name = ingestion.ff_json_standard)
pattern = '.*web_events_.*[.]json'
on_error = abort_statement
force = true;

set copy_query_id = (select last_query_id());

create or replace temp table tmp_web_events_copy_result as
Select * from table (result_scan($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.web_events',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/semi_structured/web_events/',
    'JSON',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM tmp_web_events_copy_result;

-----------------------------------------------------------------------------------------------------------------------
-- Web Events Load - End
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- Support Tickets Load - Start
-----------------------------------------------------------------------------------------------------------------------

copy into raw.support_tickets (
    v1,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts
)
from (
    Select
        $1::variant, -- v1,
        metadata$filename::text, -- source_file_name,
        metadata$file_row_number::number, -- source_row_number,
        $batch_id::text, -- batch_id,
        current_timestamp() -- load_ts
    from @ingestion.STG_S3_INGESTION_LAB/incoming/semi_structured/support_tickets/
)
file_format = (format_name = ingestion.ff_json_standard)
pattern = '.*support_tickets_.*[.]json'
on_error = abort_statement
force = true;

set copy_query_id = (select last_query_id());

create or replace temp table tmp_support_tickets_copy_result as
Select * from table (result_scan($copy_query_id));

INSERT INTO AUDIT.LOAD_FILE (
    load_file_id,
    batch_id,
    target_table_name,
    source_file_name,
    source_stage_name,
    source_stage_path,
    file_type,
    load_method,
    load_status,
    rows_parsed,
    rows_loaded,
    rows_failed,
    first_error_message,
    first_error_line,
    first_error_character,
    first_error_column_name,
    copy_query_id,
    load_started_at,
    load_completed_at
)
SELECT
    UUID_STRING(),
    $batch_id,
    'RAW.support_tickets',
    "file",
    'STG_S3_INGESTION_LAB',
    'incoming/semi_structured/support_tickets/',
    'JSON',
    'COPY_INTO',
    "status",
    "rows_parsed",
    "rows_loaded",
    "errors_seen",
    "first_error",
    "first_error_line",
    "first_error_character",
    "first_error_column_name",
    $copy_query_id,
    $load_started_at,
    CURRENT_TIMESTAMP()
FROM tmp_support_tickets_copy_result;


-----------------------------------------------------------------------------------------------------------------------
-- Support Tickets Load - End
-----------------------------------------------------------------------------------------------------------------------


UPDATE AUDIT.LOAD_BATCH
SET
    batch_status = 'COMPLETED',
    completed_at = CURRENT_TIMESTAMP(),
    total_files_loaded = (
        SELECT COUNT(*)
        FROM AUDIT.LOAD_FILE
        WHERE batch_id = $batch_id
    ),
    total_rows_loaded = (
        SELECT COALESCE(SUM(rows_loaded), 0)
        FROM AUDIT.LOAD_FILE
        WHERE batch_id = $batch_id
    ),
    total_rows_failed = (
        SELECT COALESCE(SUM(rows_failed), 0)
        FROM AUDIT.LOAD_FILE
        WHERE batch_id = $batch_id
    )
WHERE batch_id = $batch_id;


