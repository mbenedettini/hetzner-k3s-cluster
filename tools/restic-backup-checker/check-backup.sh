#!/bin/bash
set -uo pipefail

TODAY=$(date -u +%Y-%m-%d)
echo "Checking for restic backup on $TODAY..."

if ! SNAPSHOTS=$(restic snapshots --latest 1 2>&1); then
    MSG="Error: Could not list restic snapshots for $RESTIC_REPOSITORY. Output: $SNAPSHOTS"
    echo "$MSG"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
        --data-urlencode "text=🚨 ${MSG}" || echo "Warning: Failed to send Telegram notification"
    exit 1
fi

echo "$SNAPSHOTS"

if echo "$SNAPSHOTS" | grep -q "$TODAY"; then
    echo "SUCCESS: Backup found for $TODAY"
    exit 0
else
    MSG="No restic backup found for $TODAY for repository $RESTIC_REPOSITORY"
    echo "FAILURE: $MSG"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
        --data-urlencode "text=⚠️ ${MSG}" || echo "Warning: Failed to send Telegram notification"
    exit 1
fi
