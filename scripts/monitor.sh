#!/bin/bash
# OSWorld Monitoring Script
# Usage: ./scripts/monitor.sh [result_dir]

RESULT_DIR="${1:-results_maverick_full}"
REFRESH_INTERVAL=10

while true; do
    clear
    echo "═══════════════════════════════════════════════════════════════"
    echo "  🚀 OSWorld Full Test - Live Monitor"
    echo "  📂 Result Directory: $RESULT_DIR"
    echo "  ⏰ $(date '+%Y-%m-%d %H:%M:%S')"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    # Check if result directory exists
    if [ -d "$RESULT_DIR" ]; then
        # Count completed tasks
        COMPLETED=$(find "$RESULT_DIR" -name 'result.txt' 2>/dev/null | wc -l)
        echo "📊 Tasks Completed: $COMPLETED"
        
        # Calculate success rate
        if [ $COMPLETED -gt 0 ]; then
            SUCCESS=$(find "$RESULT_DIR" -name 'result.txt' -exec grep -l "^1" {} \; 2>/dev/null | wc -l)
            SUCCESS_RATE=$(echo "scale=2; $SUCCESS * 100 / $COMPLETED" | bc)
            echo "✅ Successful: $SUCCESS ($SUCCESS_RATE%)"
            echo "❌ Failed: $((COMPLETED - SUCCESS))"
        fi
        
        # Disk usage
        DISK_USAGE=$(du -sh "$RESULT_DIR" 2>/dev/null | cut -f1)
        echo "💾 Disk Usage: $DISK_USAGE"
    else
        echo "⚠️  Result directory not found: $RESULT_DIR"
    fi
    
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "🐳 Docker Containers:"
    echo "───────────────────────────────────────────────────────────────"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers running"
    
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "🖥️  System Resources:"
    echo "───────────────────────────────────────────────────────────────"
    echo "Memory:"
    free -h | grep Mem | awk '{print "  Total: "$2"  Used: "$3"  Free: "$4}'
    echo "Disk:"
    df -h / | tail -1 | awk '{print "  Total: "$2"  Used: "$3"  Available: "$4" ("$5" used)"}'
    
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "📈 Recent Activity (Last 5 log lines):"
    echo "───────────────────────────────────────────────────────────────"
    if ls logs/full_run_*.log logs/small_run_*.log 2>/dev/null | tail -1 | xargs -I {} tail -n 5 {} 2>/dev/null | grep -v "^$"; then
        :
    else
        echo "No recent logs found"
    fi
    
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "Press Ctrl+C to exit | Refreshing every ${REFRESH_INTERVAL}s"
    echo "═══════════════════════════════════════════════════════════════"
    
    sleep $REFRESH_INTERVAL
done

