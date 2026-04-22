#!/bin/bash
set -euo pipefail

TODAY=$(date -u +%Y-%m-%d)
echo "Checking for restic backup on $TODAY..."

SNAPSHOTS=$(restic snapshots 2>&1)
echo "$SNAPSHOTS"

if echo "$SNAPSHOTS" | grep -q "$TODAY"; then
    echo "SUCCESS: Backup found for $TODAY"
    exit 0
else
    MSG="No restic backup found for $TODAY for repository $RESTIC_REPOSITORY"
    echo "FAILURE: $MSG"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="⚠️ ${MSG}" || echo "Warning: Failed to send Telegram notification"
    exit 1
fi
