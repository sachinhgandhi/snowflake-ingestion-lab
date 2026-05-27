To connect Snowflake using Snowflake CLI :-

1. In terminal :-
   1. Check snowflake CLI is installed or not :- snow --version or snow --info
   2. Add / configure connection :- snow connection add
      1. Account: BQYLQNO-WR14298 (Account Identifier)
   3. List connections :- snow connection list
   4. Test connection :- snow connection test --connection <connection_name>
   5. SQL test :- snow sql -c ingestion_lab_conn -q "SELECT CURRENT_USER(), CURRENT_ROLE(), CURRENT_ACCOUNT();"
   6. Execute Script :- snow sql -c ingestion_lab_conn -f snowflake/00_account_setup/001_create_roles.sql
   7. To update connection details in existing connection :-
      1. Remove existing connection :-
         1. snow connection list
         2. snow connection remove ingestion_lab_conn
