use role INGESTION_LAB_DEVELOPER_ROLE;
use warehouse INGESTION_LAB_WH;
use database INGESTION_LAB_DB;

create or replace procedure landing.sp_notifiy_landing_load_status(
    v_subject string,
    v_message string
)
returns string
language sql
As
$$
    
Begin

    call system$send_email(
        'INT_Email_Ingestion_Lab',
        'sachin.h.gandhi@gmail.com',
        :v_subject,
        :v_message 
    );

    return 'Email sent successfully.';
End;

$$;