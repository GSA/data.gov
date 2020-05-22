#!/bin/bash

# capture resource stats every 15 seconds.
# it might help to find the right threshold
# so apache can be restarted before server goes down.

# TIME: timestamp in UTC
# MEM: memory used in percentage.
# MEM_TOP: command using most memory
# CPU_AVG: one minute average of CPU load
# CPU_CURRENT: current CPU usage
# CPU_TOP: command using most CPU

interval_in_seconds=15

while true
do
  TIME=$(date '+%Y-%m-%d %H:%M:%S')
  MEM=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
  MEM_TOP=$(ps -eo cmd,%mem --sort=-%mem | awk 'NR==2{printf "%.1f%% %s", $NF, $1}')
  CPU_AVG=$(top -bn1 | grep load | awk '{printf "%i%%", $(NF-2)*100}')
  CPU_CURRENT=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%", prefix, 100 - v }')
  CPU_TOP=$(ps -eo cmd,%cpu --sort=-%cpu | awk 'NR==2{printf "%.1f%% %s", $NF, $1}')

  echo -e "$TIME\t$MEM\t($MEM_TOP)\t$CPU_AVG\t$CPU_CURRENT\t($CPU_TOP)"
  sleep $interval_in_seconds
done
