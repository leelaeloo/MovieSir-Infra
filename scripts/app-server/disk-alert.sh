#!/bin/bash

# 설정
THRESHOLD=80  # 경고 기준 (%)
LOG_FILE="/var/log/disk-alert.log"

# 디스크 사용량 확인
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# 로그 기록
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Disk usage: ${USAGE}%" >> $LOG_FILE

# 임계치 초과 시 경고
if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Disk usage exceeded ${THRESHOLD}%" >> $LOG_FILE

    # 용량 많이 차지하는 디렉토리 확인
    echo "Top 5 directories:" >> $LOG_FILE
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -5 >> $LOG_FILE
fi
