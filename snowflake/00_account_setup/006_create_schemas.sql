use role INGESTION_LAB_ADMIN_ROLE;
USE DATABASE INGESTION_LAB_DB;

CREATE SCHEMA IF NOT EXISTS RAW WITH MANAGED ACCESS
    COMMENT = 'Stores raw ingested data from S3';

CREATE SCHEMA IF NOT EXISTS AUDIT WITH MANAGED ACCESS
    COMMENT = 'Stores load audit logs, rejected record tracking, and monitoring data';

CREATE SCHEMA IF NOT EXISTS INGESTION WITH MANAGED ACCESS
    COMMENT = 'Stores ingestion related all objects';

CREATE SCHEMA IF NOT EXISTS Landing WITH MANAGED ACCESS
    COMMENT = 'Stores data read from Streams';

CREATE SCHEMA IF NOT EXISTS CURATED WITH MANAGED ACCESS
    COMMENT = 'Stores processed output tables before dbt transformation layer';

SHOW SCHEMAS IN DATABASE INGESTION_LAB_DB;