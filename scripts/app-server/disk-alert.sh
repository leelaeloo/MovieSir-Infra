#!/bin/bash

LOG_FILE=/var/log/disk-alert.log
THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "=== Disk Check: $(date) ===" >> $LOG_FILE
echo "Current Usage: ${USAGE}%" >> $LOG_FILE

if [ $USAGE -gt $THRESHOLD ]; then
    echo "⚠️ WARNING: 디스크 사용률 ${USAGE}% - 정리 필요!" >> $LOG_FILE

    # Top 5 디렉토리
    echo "📁 Top 5 directories:" >> $LOG_FILE
    du -sh /* 2>/dev/null | sort -rh | head -5 >> $LOG_FILE
fi
