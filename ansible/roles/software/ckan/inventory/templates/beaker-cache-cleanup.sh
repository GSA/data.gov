#!/bin/bash

# https://github.com/GSA/datagov-deploy/issues/682
# delete stale session rows in beaker_cache table.

age_in_days=7
LOCKFILE=/tmp/beaker_cache_cleanup.sh.pid

if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT

echo $$ > ${LOCKFILE}

psql -h {{ inventory_ckan_db_host }} -U {{ inventory_db_user }} {{ inventory_db_name }} <<SQL
DELETE FROM BEAKER_CACHE WHERE ACCESSED < CURRENT_TIMESTAMP - INTERVAL '$age_in_days day'
SQL

rm -f ${LOCKFILE}
