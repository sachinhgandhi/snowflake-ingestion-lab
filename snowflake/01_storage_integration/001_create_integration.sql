USE ROLE INGESTION_LAB_ADMIN_ROLE;
use warehouse INGESTION_LAB_WH;

CREATE STORAGE INTEGRATION IF NOT EXISTS INT_AWS_S3_INGESTION_LAB
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::498976383720:role/snowflake-ingestion-lab-role'
    STORAGE_ALLOWED_LOCATIONS = (
        's3://snowflake-ingestion-lab/'
    )
    COMMENT = 'Storage integration for AWS S3 ingestion lab external stages';

Create Notification Integration if not exists INT_Email_Ingestion_Lab
    Type = email
    enabled = true
    allowed_recipients = (
        'sachin.h.gandhi@gmail.com'
    );

DESC INTEGRATION INT_AWS_S3_INGESTION_LAB;
DESC INTEGRATION INT_Email_Ingestion_Lab;