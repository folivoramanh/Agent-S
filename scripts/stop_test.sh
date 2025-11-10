#!/bin/bash
# Stop OSWorld Test
# Usage: ./scripts/stop_test.sh [pid_file]

PID_FILE="${1:-run_full.pid}"

if [ ! -f "$PID_FILE" ]; then
    echo "❌ PID file not found: $PID_FILE"
    echo ""
    echo "Available PID files:"
    ls -1 run_*.pid 2>/dev/null || echo "  None found"
    echo ""
    echo "Running python processes:"
    ps aux | grep "run_local.py" | grep -v grep
    exit 1
fi

PID=$(cat "$PID_FILE")

if ! ps -p $PID > /dev/null; then
    echo "⚠️  Process $PID is not running"
    rm -f "$PID_FILE"
    exit 0
fi

echo "🛑 Stopping process $PID..."
echo ""
ps -p $PID -o pid,etime,cmd

echo ""
echo "Sending SIGTERM signal..."
kill $PID

# Wait for graceful shutdown
for i in {1..30}; do
    if ! ps -p $PID > /dev/null; then
        echo "✅ Process stopped gracefully"
        rm -f "$PID_FILE"
        
        # Clean up Docker containers
        echo ""
        echo "🐳 Cleaning up Docker containers..."
        docker stop $(docker ps -aq) 2>/dev/null
        docker rm $(docker ps -aq) 2>/dev/null
        echo "✅ Docker cleanup completed"
        
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo ""
echo "⚠️  Process did not stop gracefully, force killing..."
kill -9 $PID
rm -f "$PID_FILE"

# Clean up Docker
echo "🐳 Cleaning up Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

echo "✅ Process force stopped"

