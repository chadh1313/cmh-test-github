#!/bin/bash

# Define thresholds
CPU_THRESHOLD="${CPU_THRESHOLD}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD}"

# Fetch resource usage data for all pods
resource_data=$(kubectl top pods --all-namespaces -o json | jq -r '.items[] | "\(.metadata.name)t\(.metrics.cpu.usage.average)t\(.metrics.memory.usage.average)"')

# Process the data and filter out pods exceeding thresholds
echo "$resource_data" | while read -r pod_name cpu_usage mem_usage; do
    cpu_percent=$(echo "scale=2; $cpu_usage / 1000000000 * 100" | bc)
    memory_percent=$(echo "scale=2; $mem_usage / 1000000000 * 100" | bc)

    if (( $(echo "$cpu_percent > $CPU_THRESHOLD" | bc -l) )); then
        echo "Pod $pod_name is consuming excessive CPU: $cpu_percent%"
    fi

    if (( $(echo "$memory_percent > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "Pod $pod_name is consuming excessive memory: $memory_percent%"
    fi
done