#!/bin/bash

cube_and_divide() {
    echo "scale=10; ($1^3) / 2" | bc
}

get_memory_usage() {
    ps -o rss= -p "$$" | awk '{print $1 * 1024}'
}

get_total_memory_usage() {
    local total_memory=$(get_memory_usage)
    for pid in "${child_pids[@]}"; do
        if ps -p "$pid" > /dev/null 2>&1; then
            local child_memory=$(ps -o rss= -p "$pid" | awk '{print $1 * 1024}')
            total_memory=$((total_memory + child_memory))
        fi
    done
    echo "$total_memory"
}

main() {
    local x=2
    local tolerance=1e-9
    local iteration=0
    local script_name=$(basename "$0")
    declare -a child_pids

    while true; do
        iteration=$((iteration + 1))
        x=$(cube_and_divide "$x")

        # Spawn a new instance if x is close to 2
        if [ "$(echo "scale=10; $x - 2 < $tolerance && $x - 2 > -$tolerance" | bc)" -eq 1 ]; then
            bash "$0" &
            child_pids+=($!)
            echo "Spawned a new instance at iteration $iteration with value 2"
        fi

        # Check if x deviates from expected values
        if [ "$(echo "scale=10; ($x - sqrt(2) < $tolerance && $x - sqrt(2) > -$tolerance) || ($x - (sqrt(2)^3 / 2) < $tolerance && $x - (sqrt(2)^3 / 2) > -$tolerance) || ($x - 2 < $tolerance && $x - 2 > -$tolerance)" | bc)" -eq 0 ]; then
            echo "Deviation detected at iteration $iteration with value $x"
            break
        fi

        total_memory_usage=$(get_total_memory_usage)
        echo "$script_name - Total memory usage: $(echo "scale=2; $total_memory_usage / (1024 * 1024)" | bc) MB"
        sleep 1
    done
}

# Ensure cleanup of child processes on exit
trap 'for pid in "${child_pids[@]}"; do kill "$pid"; done' EXIT

main
