#!/bin/bash

echo "=== 주간 서버 정리 시작: $(date) ==="

# 1. Journal 로그 정리
echo "📋 Journal 로그 정리..."
sudo journalctl --vacuum-time=7d

# 2. Docker 정리
echo "🐳 Docker 정리..."
docker system prune -f

# 3. 디스크 상태 확인
echo "💾 디스크 상태:"
df -h /

echo "=== 정리 완료: $(date) ==="
