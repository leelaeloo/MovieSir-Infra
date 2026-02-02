#!/bin/bash

LOG_FILE="/var/log/weekly-cleanup.log"
echo "====== Weekly Cleanup Started: $(date) ======" >> $LOG_FILE

# 1. 시스템 로그 정리 (7일 이전)
echo "[$(date '+%H:%M:%S')] Cleaning system logs..." >> $LOG_FILE
sudo journalctl --vacuum-time=7d >> $LOG_FILE 2>&1

# 2. Docker 정리
echo "[$(date '+%H:%M:%S')] Cleaning Docker..." >> $LOG_FILE
docker system prune -f >> $LOG_FILE 2>&1
docker builder prune -f >> $LOG_FILE 2>&1

# 3. 임시 파일 정리
echo "[$(date '+%H:%M:%S')] Cleaning temp files..." >> $LOG_FILE
sudo rm -rf /tmp/* 2>/dev/null

# 4. 정리 후 디스크 용량 확인
echo "[$(date '+%H:%M:%S')] Disk usage after cleanup:" >> $LOG_FILE
df -h / >> $LOG_FILE

echo "====== Weekly Cleanup Completed: $(date) ======" >> $LOG_FILE
