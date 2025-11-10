#!/bin/bash
# OSWorld Results Backup Script
# Usage: ./scripts/backup_results.sh [result_dir]

RESULT_DIR="${1:-results_maverick_full}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/backup_${TIMESTAMP}"

echo "🔄 Starting backup..."
echo "📂 Source: $RESULT_DIR"
echo "💾 Destination: $BACKUP_DIR"

if [ ! -d "$RESULT_DIR" ]; then
    echo "❌ Error: Result directory not found: $RESULT_DIR"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Backup excluding large image files (optional - can include them)
echo "📦 Copying files (excluding screenshots to save space)..."
rsync -av --exclude="*.png" --exclude="*.mp4" \
    "$RESULT_DIR/" "$BACKUP_DIR/" \
    --info=progress2

# Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo ""
echo "✅ Backup completed!"
echo "📊 Backup size: $BACKUP_SIZE"
echo "📁 Location: $BACKUP_DIR"

# Create backup manifest
cat > "$BACKUP_DIR/BACKUP_INFO.txt" << EOF
Backup Information
==================
Date: $(date)
Source: $RESULT_DIR
Size: $BACKUP_SIZE
Files: $(find "$BACKUP_DIR" -type f | wc -l)
Tasks: $(find "$BACKUP_DIR" -name "result.txt" | wc -l)

Note: Screenshots (*.png) and videos (*.mp4) were excluded to save space.
EOF

echo ""
echo "📄 Backup manifest created: $BACKUP_DIR/BACKUP_INFO.txt"

# Keep only last 5 backups (optional)
BACKUP_COUNT=$(ls -d backups/backup_* 2>/dev/null | wc -l)
if [ $BACKUP_COUNT -gt 5 ]; then
    echo ""
    echo "🧹 Cleaning old backups (keeping last 5)..."
    ls -dt backups/backup_* | tail -n +6 | xargs rm -rf
    echo "✅ Cleanup completed"
fi

