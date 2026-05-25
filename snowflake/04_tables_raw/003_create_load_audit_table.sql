USE ROLE INGESTION_LAB_DEVELOPER_ROLE;
USE DATABASE INGESTION_LAB_DB;

CREATE TABLE IF NOT EXISTS AUDIT.LOAD_BATCH (
    batch_id text,
    batch_name text,
    source_system text,
    load_method text,
    batch_status text,
    started_at timestamp_ltz,
    completed_at timestamp_ltz,
    total_files_expected number,
    total_files_loaded number,
    total_rows_loaded number,
    total_rows_failed number,
    created_by text,
    created_at timestamp_ltz default current_timestamp()
);

CREATE TABLE IF NOT EXISTS AUDIT.LOAD_FILE (
    load_file_id text,
    batch_id text,
    target_table_name text,
    source_file_name text,
    source_stage_name text,
    source_stage_path text,
    file_type text,
    load_method text,
    load_status text,
    rows_parsed number,
    rows_loaded number,
    rows_failed number,
    first_error_message text,
    first_error_line number,
    first_error_character number,
    first_error_column_name text,
    copy_query_id text,
    load_started_at timestamp_ltz,
    load_completed_at timestamp_ltz,
    created_at timestamp_ltz default current_timestamp()
);

CREATE TABLE IF NOT EXISTS AUDIT.LOAD_ERROR (
    error_id text,
    batch_id text,
    target_table_name text,
    source_file_name text,
    source_row_number number,
    error_code text,
    error_message text,
    error_column_name text,
    raw_record text,
    error_created_at timestamp_ltz default current_timestamp()
);