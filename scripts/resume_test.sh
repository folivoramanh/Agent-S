#!/bin/bash
# Resume interrupted OSWorld test
# Usage: ./scripts/resume_test.sh [result_dir]

RESULT_DIR="${1}"

if [ -z "$RESULT_DIR" ]; then
    echo "❌ Error: Please specify result directory"
    echo "Usage: ./scripts/resume_test.sh <result_dir>"
    echo ""
    echo "Available result directories:"
    ls -d results_maverick_* 2>/dev/null || echo "  None found"
    exit 1
fi

if [ ! -d "$RESULT_DIR" ]; then
    echo "❌ Error: Result directory not found: $RESULT_DIR"
    exit 1
fi

echo "🔄 Resuming test from: $RESULT_DIR"
echo ""

# Determine test type from directory structure
if [ -f "$RESULT_DIR/pyautogui/screenshot/meta-llama-4-maverick-17b-128e-instruct/args.json" ]; then
    ARGS_FILE="$RESULT_DIR/pyautogui/screenshot/meta-llama-4-maverick-17b-128e-instruct/args.json"
    
    # Extract parameters from args.json
    TEST_FILE=$(python3 -c "import json; f=open('$ARGS_FILE'); d=json.load(f); print(d.get('test_all_meta_path', 'evaluation_examples/test_nogdrive.json'))")
    DOMAIN=$(python3 -c "import json; f=open('$ARGS_FILE'); d=json.load(f); print(d.get('domain', 'all'))")
    
    echo "📋 Found previous configuration:"
    echo "   Test file: $TEST_FILE"
    echo "   Domain: $DOMAIN"
else
    echo "⚠️  No args.json found, using defaults"
    TEST_FILE="evaluation_examples/test_nogdrive.json"
    DOMAIN="all"
fi

# Count completed and remaining tasks
COMPLETED=$(find "$RESULT_DIR" -name "result.txt" 2>/dev/null | wc -l)
echo ""
echo "📊 Current progress: $COMPLETED tasks completed"
echo ""

# Set environment
if [ -z "$OPENAI_API_KEY" ]; then
    export OPENAI_API_KEY=""
fi
export TOKENIZERS_PARALLELISM="false"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="logs/resume_${TIMESTAMP}.log"
PID_FILE="run_resumed.pid"

echo "✅ Resuming test (will skip completed tasks)..."
echo "📝 Log file: $LOG_FILE"
echo ""

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

echo $! > "$PID_FILE"
PID=$(cat "$PID_FILE")

echo "✅ Resumed successfully!"
echo ""
echo "📊 Process Information:"
echo "   PID: $PID"
echo "   Log: $LOG_FILE"
echo ""
echo "📈 To monitor: ./scripts/monitor.sh $RESULT_DIR"
echo "🛑 To stop: kill $PID"

