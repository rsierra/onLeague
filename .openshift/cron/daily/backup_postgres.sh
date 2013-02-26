#!/bin/bash
# Backs up the OpenShift PostgreSQL database for this application
# by Skye Book <skye.book@gmail.com>

NOW="$(date +"%Y-%m-%d")"
FILENAME="$OPENSHIFT_DATA_DIR/db_backups/$OPENSHIFT_APP_NAME.$NOW.backup.sql.gz"
pg_dump -U $OPENSHIFT_DB_USERNAME -h $OPENSHIFT_DB_HOST -w $OPENSHIFT_APP_NAME | gzip > $FILENAME
