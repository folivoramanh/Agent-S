#!/bin/bash
# Check for errors in logs
# Usage: ./scripts/check_errors.sh [log_file]

LOG_PATTERN="${1:-logs/run_*.log}"

echo "🔍 Checking for errors in: $LOG_PATTERN"
echo ""

# Find all matching log files
LOG_FILES=$(ls $LOG_PATTERN 2>/dev/null)

if [ -z "$LOG_FILES" ]; then
    echo "❌ No log files found matching: $LOG_PATTERN"
    exit 1
fi

# Check each log file
for LOG_FILE in $LOG_FILES; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 File: $LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Count different types of messages
    ERROR_COUNT=$(grep -i "error" "$LOG_FILE" 2>/dev/null | grep -v "error_handler" | wc -l)
    EXCEPTION_COUNT=$(grep -i "exception" "$LOG_FILE" 2>/dev/null | wc -l)
    FAILED_COUNT=$(grep -i "failed" "$LOG_FILE" 2>/dev/null | wc -l)
    WARNING_COUNT=$(grep -i "warning" "$LOG_FILE" 2>/dev/null | wc -l)
    
    echo "❌ Errors: $ERROR_COUNT"
    echo "⚠️  Exceptions: $EXCEPTION_COUNT"
    echo "💥 Failed: $FAILED_COUNT"
    echo "⚡ Warnings: $WARNING_COUNT"
    
    # Show recent errors if any
    if [ $ERROR_COUNT -gt 0 ] || [ $EXCEPTION_COUNT -gt 0 ]; then
        echo ""
        echo "Recent errors/exceptions (last 10):"
        echo "───────────────────────────────────────────────────────────"
        grep -i "error\|exception" "$LOG_FILE" | grep -v "error_handler" | tail -10
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Error check completed"

