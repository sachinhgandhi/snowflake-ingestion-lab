USE ROLE INGESTION_LAB_ADMIN_ROLE;

create database if not exists INGESTION_LAB_DB
    COMMENT = 'Database for ingestion lab project';

SHOW DATABASES LIKE 'INGESTION_LAB_DB';