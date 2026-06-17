USE ROLE INGESTION_LAB_ADMIN_ROLE;
use warehouse INGESTION_LAB_WH;

grant usage on integration INT_AWS_S3_INGESTION_LAB to role INGESTION_LAB_DEVELOPER_ROLE;
grant usage on integration INT_Email_Ingestion_Lab to role INGESTION_LAB_DEVELOPER_ROLE;