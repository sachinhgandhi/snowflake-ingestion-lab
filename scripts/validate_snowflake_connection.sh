#!/bin/bash

set -e

CONNECTION_NAME="${1:-ingestion_lab_admin}"

snow connection test -c "$CONNECTION_NAME"

snow sql -c "$CONNECTION_NAME" -q "
SELECT
    CURRENT_USER()      AS current_user,
    CURRENT_ROLE()      AS current_role,
    CURRENT_ACCOUNT()   AS current_account,
    CURRENT_REGION()    AS current_region;
"