#!/bin/bash
# OSWorld Full Test Runner
# Usage: ./scripts/run_full_test.sh [small|full|domain_name]

set -e  # Exit on error

# Configuration
TEST_TYPE="${1:-full}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Set test parameters based on type
case "$TEST_TYPE" in
    "small")
        TEST_FILE="evaluation_examples/test_small.json"
        RESULT_DIR="results_maverick_small_${TIMESTAMP}"
        DOMAIN="all"
        echo "🧪 Running SMALL test set (~50 tasks)"
        ;;
    "full")
        TEST_FILE="evaluation_examples/test_nogdrive.json"
        RESULT_DIR="results_maverick_full_${TIMESTAMP}"
        DOMAIN="all"
        echo "🚀 Running FULL test set (~300 tasks)"
        ;;
    *)
        # Assume it's a domain name
        TEST_FILE="evaluation_examples/test_nogdrive.json"
        RESULT_DIR="results_maverick_${TEST_TYPE}_${TIMESTAMP}"
        DOMAIN="$TEST_TYPE"
        echo "🎯 Running domain: $DOMAIN"
        ;;
esac

# Check environment
echo "🔍 Checking environment..."

if ! conda info --envs | grep -q "osworld"; then
    echo "❌ Error: Conda environment 'osworld' not found"
    exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  Warning: OPENAI_API_KEY not set, setting from default..."
    export OPENAI_API_KEY=""
fi

export TOKENIZERS_PARALLELISM="false"

# Create log directory
mkdir -p logs

LOG_FILE="logs/run_${TEST_TYPE}_${TIMESTAMP}.log"
PID_FILE="run_${TEST_TYPE}.pid"

echo "📝 Log file: $LOG_FILE"
echo "📂 Result directory: $RESULT_DIR"
echo ""

# Confirmation
echo "⚠️  This will run for several hours/days depending on test size."
echo "   Press Ctrl+C within 5 seconds to cancel..."
sleep 5

echo ""
echo "✅ Starting OSWorld test..."
echo ""

# Run the test
cd /localhome/local-amtrinh/OSWorld

nohup conda run -n osworld python s3/run_local.py \
  --provider_name "docker" \
  --headless \
  --max_steps 50 \
  --domain "$DOMAIN" \
  --test_all_meta_path "$TEST_FILE" \
  --result_dir "$RESULT_DIR" \
  --screen_width 1920 \
  --screen_height 1080 \
  --sleep_after_execution 1.0 \
  --model_provider "openai" \
  --model "meta/llama-4-maverick-17b-128e-instruct" \
  --model_url "https://integrate.api.nvidia.com/v1" \
  --model_api_key "$OPENAI_API_KEY" \
  --model_temperature 1.0 \
  --ground_provider "openai" \
  --ground_url "http://10.176.188.143:5050/v1" \
  --ground_api_key "dummy-key" \
  --ground_model "ui-tars" \
  --grounding_width 1920 \
  --grounding_height 1080 \
  --max_trajectory_length 8 \
  > "$LOG_FILE" 2>&1 &

# Save PID
echo $! > "$PID_FILE"
PID=$(cat "$PID_FILE")

echo "✅ Started successfully!"
echo ""
echo "📊 Process Information:"
echo "   PID: $PID"
echo "   Log: $LOG_FILE"
echo "   Results: $RESULT_DIR"
echo "   PID file: $PID_FILE"
echo ""
echo "📈 To monitor progress:"
echo "   ./scripts/monitor.sh $RESULT_DIR"
echo "   tail -f $LOG_FILE"
echo "   python scripts/check_progress.py $RESULT_DIR"
echo ""
echo "🛑 To stop:"
echo "   kill $PID"
echo "   # or"
echo "   kill \$(cat $PID_FILE)"
echo ""
echo "🎉 Test is running in background!"

