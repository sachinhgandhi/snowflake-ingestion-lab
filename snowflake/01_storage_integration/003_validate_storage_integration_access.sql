USE ROLE INGESTION_LAB_ADMIN_ROLE;
use warehouse INGESTION_LAB_WH;

SELECT
  SYSTEM$VALIDATE_STORAGE_INTEGRATION(
    'INT_AWS_S3_INGESTION_LAB',
    's3://snowflake-ingestion-lab/',
    'incoming/structured/customers/1.csv', 'all');
