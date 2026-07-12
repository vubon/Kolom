#!/bin/bash

# Exit on interrupt
trap "echo -e '\nMemory monitoring stopped.'; exit 0" SIGINT

PROCESS_NAME="Kolom"

echo "Looking for process: $PROCESS_NAME..."
PID=$(pgrep -x "$PROCESS_NAME")

if [ -z "$PID" ]; then
    echo "Error: $PROCESS_NAME is not running. Please start the Kolom app first."
    exit 1
fi

echo "Monitoring Memory (RSS) for $PROCESS_NAME (PID: $PID)..."
echo "Press Ctrl+C to stop."
echo "------------------------------------------------------"
echo "Timestamp, RSS Memory (MB), CPU %"

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    # Using ps to get RSS in KB, then converting to MB
    # -o rss: Resident Set Size in kilobytes
    # -o pcpu: CPU usage percentage
    PS_OUTPUT=$(ps -p "$PID" -o rss= -o pcpu=)
    
    if [ -z "$PS_OUTPUT" ]; then
        echo "Process $PID stopped. Exiting monitor."
        exit 1
    fi
    
    RSS_KB=$(echo $PS_OUTPUT | awk '{print $1}')
    CPU_PCT=$(echo $PS_OUTPUT | awk '{print $2}')
    
    RSS_MB=$(echo "scale=2; $RSS_KB / 1024" | bc)
    
    echo "$TIMESTAMP, ${RSS_MB}MB, ${CPU_PCT}%"
    
    # Poll every 1 second
    sleep 1
done
