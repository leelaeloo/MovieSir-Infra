#!/bin/bash

LOG_FILE=~/logs/weekly-cleanup-$(date +%Y%m%d).log
mkdir -p ~/logs

echo "=== 주간 서버 정리 시작: $(date) ===" | tee -a $LOG_FILE

# 1. Journal 로그 정리
echo "📋 Journal 로그 정리..." | tee -a $LOG_FILE
sudo journalctl --vacuum-time=7d 2>&1 | tee -a $LOG_FILE

# 2. Docker 정리
echo "🐳 Docker 정리..." | tee -a $LOG_FILE
docker system prune -f 2>&1 | tee -a $LOG_FILE
docker builder prune -f 2>&1 | tee -a $LOG_FILE

# 3. 임시 파일 정리
echo "🗑️ 임시 파일 정리..." | tee -a $LOG_FILE
sudo rm -rf /tmp/* 2>/dev/null

# 4. 디스크 상태 확인
echo "💾 디스크 상태:" | tee -a $LOG_FILE
df -h / | tee -a $LOG_FILE

echo "=== 정리 완료: $(date) ===" | tee -a $LOG_FILE
