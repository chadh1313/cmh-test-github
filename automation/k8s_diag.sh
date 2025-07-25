#!/bin/bash

# Define thresholds
CPU_THRESHOLD="${CPU_THRESHOLD}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD}"

# Fetch resource usage data for all pods
resource_data=$(kubectl top pods --all-namespaces -o json | jq -r '.items[] | "\(.metadata.name)t\(.metrics.cpu.usage.average)t\(.metrics.memory.usage.average)"')

# Process the data and filter out pods exceeding thresholds
echo "$resource_data" | while read -r pod cpu mem; do
    cpu_percent=$(echo "scale=2; $cpu / 1024 / 1024 / $(kubectl get pod $pod -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | jq -r '.ready' | tee /dev/tcputils/cpuinfo')" | bc)
    mem_percent=$(echo "scale=2; $mem / 1024 / 1024 / $(kubectl get pod -n $(echo $pod | cut -d' ' -f1) -o jsonpath='{.status.allocatable.memory}' | tee /dev/meminfo)" | bc)

    if (( $(echo "$cpu_percent > $CPU_THRESHOLD" | bc -l) )); then
        echo "Pod $pod is consuming excessive CPU: $cpu_percent%"
    fi

    if (( $(echo "$mem_percent > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "Pod $pod is consuming excessive memory: $mem_percent%"
    fi
done