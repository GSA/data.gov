#!/bin/bash

MAX_INSTANCES=9
MIN_INSTANCES=3
SCALE_STEP=2

CPU_BUSY_THRESHOLD=300
CPU_IDLE_THRESHOLD=220

app_status=$(cf app catalog-web)
scale_direction=""

# This function will check the average CPU usage of all running instances of an app
function set_scale_direction {
  # Extract lines containing 'running'
  running_lines=$(echo "$app_status" | grep "#[0-9]*[[:space:]]*running")

  cpu_sum=0
  count=0

  if [ -n "$running_lines" ]; then
    while IFS= read -r line
    do
      # Extract CPU usage and remove '%' character
      cpu_usage=$(echo $line | cut -d' ' -f4 | tr -d '%')
      cpu_sum=$(echo "$cpu_sum + $cpu_usage" | bc)
      ((count++))
    done <<< "$running_lines"
  fi

  # Calculate average CPU usage
  average_cpu=$(echo "scale=2; $cpu_sum / $count" | bc)

  if [ "$(echo "$average_cpu > $CPU_BUSY_THRESHOLD" | bc)" -eq 1 ]; then
    echo "Average CPU is $average_cpu. Too High."
    scale_direction="up"
  elif [ "$(echo "$average_cpu < $CPU_IDLE_THRESHOLD" | bc)" -eq 1 ]; then
    echo "Average CPU is $average_cpu. Too Low."
    scale_direction="down"
  else
    echo "Average CPU is $average_cpu. Just Right."
    scale_direction="same"
  fi
}

function set_scale_number {
  # get the total number of instances
  total_instances=$(echo "$app_status" | grep '^instances:' | awk '{print $2}' | cut -d '/' -f 2 | head -n 1)
  # exit if the total instances is not a number
  if ! [[ "$total_instances" =~ ^[0-9]+$ ]]; then
    echo "Total instances is not a number. Exiting. Here is the output of the app status:"
    echo "$app_status"
    exit 1
  fi
  echo "Current total instances: $total_instances"
  # call the scale direction
  set_scale_direction

  # if the direction is up and the total instances is less than the max instances
  if [ "$scale_direction" == "up" ] && [ "$total_instances" -lt "$MAX_INSTANCES" ]; then
    export scale_to=$((total_instances + SCALE_STEP))
    echo "Scaling up to $scale_to"
  elif [ "$scale_direction" == "down" ] && [ "$total_instances" -gt "$MIN_INSTANCES" ]; then
    # export the scale_to value but make sure scale_to is large than 1
    export scale_to=$((total_instances - SCALE_STEP < 1 ? 1 : total_instances - SCALE_STEP))
    echo "Scaling down to $scale_to"
  else
    export scale_to="$total_instances"
    echo "Remain at the $scale_direction scale level $scale_to"
  fi
}
