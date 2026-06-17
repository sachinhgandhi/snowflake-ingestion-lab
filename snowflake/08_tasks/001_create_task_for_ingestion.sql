use role INGESTION_LAB_DEVELOPER_ROLE;
use warehouse INGESTION_LAB_WH;
use database INGESTION_LAB_DB;

-----------------------------------------------------------------------------------------------------------------------
-- Update Landing Tables - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.tsk_update_landing_tables_start
    warehouse = 'INGESTION_LAB_WH'
    schedule = '5 Minute'
As
EXECUTE IMMEDIATE
$$  
declare 
    v_subject string;
    v_message string;

Begin
    v_subject := 'Landing Schema Load Started - ' || to_varchar(current_timestamp());
    v_message := 'The process of updating records in the LANDING schema has been started.'
                || '\n Start Time - '
                || to_varchar(current_timestamp());

    call LANDING.sp_notifiy_landing_load_status(:v_subject, :v_message);
End;
$$;

-----------------------------------------------------------------------------------------------------------------------
-- Update Landing Tables - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Customer - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.tsk_process_customers
    warehouse = INGESTION_LAB_WH
    after ingestion.tsk_update_landing_tables_start
    -- when SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_CUSTOMERS_STREAM')
As
    merge into landing.customers as target
    using (
        SELECT
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
        FROM INGESTION.RAW_CUSTOMERS_STREAM
        Where METADATA$ACTION != 'DELETE'
    ) as source
    ON target.customer_id = source.customer_id

    WHEN MATCHED THEN UPDATE SET
        target.first_name = source.first_name,
        target.last_name = source.last_name,
        target.email = source.email,
        target.phone = source.phone,
        target.city = source.city,
        target.state_name = source.state_name,
        target.country = source.country,
        target.created_at = source.created_at,
        target.updated_at = source.updated_at,
        target.source_file_name = source.source_file_name,
        target.source_row_number = source.source_row_number,
        target.batch_id = source.batch_id,
        target.load_ts = source.load_ts,
        target.landing_ts = CURRENT_TIMESTAMP()

    WHEN NOT MATCHED THEN INSERT (
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
        load_ts,
        landing_ts
    )
    VALUES (
        source.customer_id,
        source.first_name,
        source.last_name,
        source.email,
        source.phone,
        source.city,
        source.state_name,
        source.country,
        source.created_at,
        source.updated_at,
        source.source_file_name,
        source.source_row_number,
        source.batch_id,
        source.load_ts,
        CURRENT_TIMESTAMP()
    );

-----------------------------------------------------------------------------------------------------------------------
-- Landing Customer - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Orders - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.TSK_PROCESS_ORDERS
    WAREHOUSE = INGESTION_LAB_WH
    after ingestion.tsk_process_customers
    -- WHEN SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_ORDERS_STREAM')
AS
MERGE INTO LANDING.ORDERS AS target
USING (
    SELECT
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
    FROM INGESTION.RAW_ORDERS_STREAM
    WHERE METADATA$ACTION != 'DELETE'
) AS source
ON target.order_id = source.order_id

WHEN MATCHED THEN UPDATE SET
    target.customer_id = source.customer_id,
    target.order_status = source.order_status,
    target.order_date = source.order_date,
    target.currency = source.currency,
    target.order_amount = source.order_amount,
    target.payment_status = source.payment_status,
    target.shipping_city = source.shipping_city,
    target.shipping_country = source.shipping_country,
    target.updated_at = source.updated_at,
    target.source_file_name = source.source_file_name,
    target.source_row_number = source.source_row_number,
    target.batch_id = source.batch_id,
    target.load_ts = source.load_ts,
    target.landing_ts = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN INSERT (
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
    load_ts,
    landing_ts
)
VALUES (
    source.order_id,
    source.customer_id,
    source.order_status,
    source.order_date,
    source.currency,
    source.order_amount,
    source.payment_status,
    source.shipping_city,
    source.shipping_country,
    source.updated_at,
    source.source_file_name,
    source.source_row_number,
    source.batch_id,
    source.load_ts,
    CURRENT_TIMESTAMP()
);

-----------------------------------------------------------------------------------------------------------------------
-- Landing Orders - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Order Items - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.TSK_PROCESS_ORDER_ITEMS
    WAREHOUSE = INGESTION_LAB_WH
    after ingestion.TSK_PROCESS_ORDERS
    -- WHEN SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_ORDER_ITEMS_STREAM')
AS
MERGE INTO LANDING.ORDER_ITEMS AS target
USING (
    SELECT
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
    FROM INGESTION.RAW_ORDER_ITEMS_STREAM
    WHERE METADATA$ACTION != 'DELETE'
) AS source
ON target.order_item_id = source.order_item_id

WHEN MATCHED THEN UPDATE SET
    target.order_id = source.order_id,
    target.product_id = source.product_id,
    target.product_name = source.product_name,
    target.category = source.category,
    target.quantity = source.quantity,
    target.unit_price = source.unit_price,
    target.line_amount = source.line_amount,
    target.source_file_name = source.source_file_name,
    target.source_row_number = source.source_row_number,
    target.batch_id = source.batch_id,
    target.load_ts = source.load_ts,
    target.landing_ts = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN INSERT (
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
    load_ts,
    landing_ts
)
VALUES (
    source.order_item_id,
    source.order_id,
    source.product_id,
    source.product_name,
    source.category,
    source.quantity,
    source.unit_price,
    source.line_amount,
    source.source_file_name,
    source.source_row_number,
    source.batch_id,
    source.load_ts,
    CURRENT_TIMESTAMP()
);

-----------------------------------------------------------------------------------------------------------------------
-- Landing Order Items - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Payments - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.TSK_PROCESS_PAYMENTS
    WAREHOUSE = INGESTION_LAB_WH
    after ingestion.TSK_PROCESS_ORDER_ITEMS
    -- WHEN SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_PAYMENTS_STREAM')
AS
MERGE INTO LANDING.PAYMENTS AS target
USING (
    SELECT
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
    FROM INGESTION.RAW_PAYMENTS_STREAM
    WHERE METADATA$ACTION != 'DELETE'
) AS source
ON target.payment_id = source.payment_id

WHEN MATCHED THEN UPDATE SET
    target.order_id = source.order_id,
    target.payment_method = source.payment_method,
    target.payment_status = source.payment_status,
    target.payment_amount = source.payment_amount,
    target.payment_timestamp = source.payment_timestamp,
    target.transaction_reference = source.transaction_reference,
    target.source_file_name = source.source_file_name,
    target.source_row_number = source.source_row_number,
    target.batch_id = source.batch_id,
    target.load_ts = source.load_ts,
    target.landing_ts = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN INSERT (
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
    load_ts,
    landing_ts
)
VALUES (
    source.payment_id,
    source.order_id,
    source.payment_method,
    source.payment_status,
    source.payment_amount,
    source.payment_timestamp,
    source.transaction_reference,
    source.source_file_name,
    source.source_row_number,
    source.batch_id,
    source.load_ts,
    CURRENT_TIMESTAMP()
);

-----------------------------------------------------------------------------------------------------------------------
-- Landing Payments - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Web Events - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.TSK_PROCESS_WEB_EVENTS
    WAREHOUSE = INGESTION_LAB_WH
    after ingestion.TSK_PROCESS_PAYMENTS
    -- WHEN SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_WEB_EVENTS_STREAM')
AS
MERGE INTO LANDING.WEB_EVENTS AS target
USING (
    SELECT
        v1,
        source_file_name,
        source_row_number,
        batch_id,
        load_ts
    FROM INGESTION.RAW_WEB_EVENTS_STREAM
    WHERE METADATA$ACTION != 'DELETE'
) AS source
ON target.v1:event_id::TEXT = source.v1:event_id::TEXT

WHEN MATCHED THEN UPDATE SET
    target.v1 = source.v1,
    target.source_file_name = source.source_file_name,
    target.source_row_number = source.source_row_number,
    target.batch_id = source.batch_id,
    target.load_ts = source.load_ts,
    target.landing_ts = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN INSERT (
    v1,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts,
    landing_ts
)
VALUES (
    source.v1,
    source.source_file_name,
    source.source_row_number,
    source.batch_id,
    source.load_ts,
    CURRENT_TIMESTAMP()
);

-----------------------------------------------------------------------------------------------------------------------
-- Landing Web Events - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Landing Support Tickets - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.TSK_PROCESS_SUPPORT_TICKETS
    WAREHOUSE = INGESTION_LAB_WH
    after ingestion.TSK_PROCESS_WEB_EVENTS
    -- WHEN SYSTEM$STREAM_HAS_DATA('INGESTION_LAB_DB.INGESTION.RAW_SUPPORT_TICKETS_STREAM')
AS
MERGE INTO LANDING.SUPPORT_TICKETS AS target
USING (
    SELECT
        v1,
        source_file_name,
        source_row_number,
        batch_id,
        load_ts
    FROM INGESTION.RAW_SUPPORT_TICKETS_STREAM
    WHERE METADATA$ACTION != 'DELETE'
) AS source
ON target.v1:ticket_id::TEXT = source.v1:ticket_id::TEXT

WHEN MATCHED THEN UPDATE SET
    target.v1 = source.v1,
    target.source_file_name = source.source_file_name,
    target.source_row_number = source.source_row_number,
    target.batch_id = source.batch_id,
    target.load_ts = source.load_ts,
    target.landing_ts = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN INSERT (
    v1,
    source_file_name,
    source_row_number,
    batch_id,
    load_ts,
    landing_ts
)
VALUES (
    source.v1,
    source.source_file_name,
    source.source_row_number,
    source.batch_id,
    source.load_ts,
    CURRENT_TIMESTAMP()
);

-----------------------------------------------------------------------------------------------------------------------
-- Landing Support Tickets - End
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-- Update Landing Tables Process Complete - Start
-----------------------------------------------------------------------------------------------------------------------

create task if not exists ingestion.tsk_update_landing_table_completed
    warehouse = INGESTION_LAB_WH
    finalize = ingestion.tsk_update_landing_tables_start
As
EXECUTE IMMEDIATE
$$  
declare 
    v_subject string;
    v_message string;

Begin
    v_subject := 'Landing Schema Load completed - ' || to_varchar(current_timestamp());
    v_message := 'The process of updating records in the LANDING schema has been completed.'
                || '\n Completed Time - '
                || to_varchar(current_timestamp());

    call LANDING.sp_notifiy_landing_load_status(:v_subject, :v_message);
End;
$$;
-----------------------------------------------------------------------------------------------------------------------
-- Update Landing Tables Process Complete - End
-----------------------------------------------------------------------------------------------------------------------


SHOW TASKS IN SCHEMA INGESTION;

SELECT SYSTEM$TASK_DEPENDENTS_ENABLE('INGESTION.TSK_UPDATE_LANDING_TABLES_START');
ALTER TASK INGESTION.tsk_update_landing_tables_start RESUME;