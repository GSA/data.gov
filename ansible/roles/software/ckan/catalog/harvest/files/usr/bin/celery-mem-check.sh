#!/bin/bash

# this script is supposed to run by cron at 5 min interval.
# it will do three mem usage checks, sleeping for 30 sec between.
# if mem usage remains high, it will restart celeryd2 workers.

LOCKFILE=/tmp/checkmem.lock
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT

echo $$ > ${LOCKFILE}

count=3

while [ "$count" -ne 0 ]
do
  freemem=$(free -m | grep 'buffers\/' | awk '{print $4}')
  if [ "$freemem" -gt 1000 ]
  then
    echo -n $(date '+%Y-%m-%d %H:%M:%S')
    echo " mem OK. $freemem free."
    break
  fi

  count=$((count-1))
  if [ "$count" -ne 0 ]
  then
    echo -n $(date '+%Y-%m-%d %H:%M:%S')
    echo " mem getting low. only $freemem free."
    sleep 30
  fi
done

# $count is 0 only if mem usage remains high for 3 checks.
if [ "$count" -eq 0 ]
then
  echo -n $(date '+%Y-%m-%d %H:%M:%S')
  echo " mem stays low!! restarting supervisord celeryd2."
  supervisorctl restart celeryd2:*
fi

rm -f ${LOCKFILE}
