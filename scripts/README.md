# 🛠️ 서버 자동화 스크립트

> MovieSir 프로젝트에서 사용한 실제 서버 자동화 스크립트입니다.

<br />

## 소개

MovieSir는 **서버 운영 자동화**를 위해 스크립트를 사용합니다.

**App Server**에서는 헬스체크, 디스크 모니터링, 주간 정리를 수행하고,<br />
**GPU Server**에서는 PostgreSQL 데이터베이스를 자동 백업합니다.

**자동화 이유:**
- **안정성** - 주기적 상태 확인으로 장애 조기 발견
- **비용 절감** - 불필요한 로그/캐시 자동 정리
- **데이터 보호** - 일일 DB 백업으로 데이터 손실 방지

---

## 주요 설정 설명

### Cron 스케줄링

스크립트를 주기적으로 실행하기 위해 cron을 사용합니다.

```bash
# crontab -e
0 8 * * 1-5 /path/to/script.sh >> /var/log/script.log 2>&1
```

| 필드 | 의미 |
|------|------|
| `0 8` | 08:00 실행 |
| `* * 1-5` | 평일 (월~금) |
| `>> /var/log/script.log` | 로그 파일 기록 |
| `2>&1` | 에러도 함께 기록 |

<br />

### 환경변수 분리

민감한 정보는 별도 파일로 분리하여 관리합니다.

```bash
# /etc/backup-db.env
DB_PASSWORD=your-password-here
```

```bash
# 스크립트에서 로드
source /etc/backup-db.env
```

---

## 파일 구성

### App Server

#### [disk-alert.sh](./app-server/disk-alert.sh)

디스크 사용률 모니터링 스크립트입니다.

```bash
# 서버 적용 경로
~/scripts/disk-alert.sh
```

- 디스크 사용률 80% 초과 시 경고 메시지 출력
- cron으로 주기적 실행 권장

```bash
THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "⚠️ 디스크 사용률 ${USAGE}% - 정리 필요!"
fi
```

---

#### [healthcheck.sh](./app-server/healthcheck.sh)

서버 상태 점검 스크립트입니다.

```bash
# 서버 적용 경로
~/scripts/healthcheck.sh
```

- Backend (FastAPI) HTTP 상태 체크
- Nginx 서비스 상태 확인
- 디스크 사용량 기록
- 메모리 사용량 기록
- 결과를 `~/logs/health-YYYYMMDD.log`에 저장

```bash
# Backend 체크
BACKEND=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)
if [ "$BACKEND" = "200" ]; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: FAIL ($BACKEND)"
fi
```

---

#### [weekly-cleanup.sh](./app-server/weekly-cleanup.sh)

주간 서버 정리 스크립트입니다.

```bash
# 서버 적용 경로
~/scripts/weekly-cleanup.sh
```

- Journal 로그 7일 이전 삭제
- Docker 미사용 리소스 정리
- 디스크 상태 출력

```bash
# Journal 로그 정리
sudo journalctl --vacuum-time=7d

# Docker 정리
docker system prune -f
```

---

### GPU Server

#### [backup-db.sh](./gpu-server/backup-db.sh)

PostgreSQL 자동 백업 스크립트입니다.

```bash
# 서버 적용 경로
/usr/local/bin/backup-db.sh

# 환경변수 파일
/etc/backup-db.env
```

- pg_dump로 데이터베이스 백업
- 7일 이상 된 백업 파일 자동 삭제
- 평일 08:00 자동 실행 (cron)

```bash
# crontab 설정 (root)
0 8 * * 1-5 /usr/local/bin/backup-db.sh >> /var/log/db-backup.log 2>&1
```

```bash
# 백업 실행
PGPASSWORD=$DB_PASSWORD pg_dump -h localhost -U $DB_USER $DB_NAME > $BACKUP_DIR/moviesir_$DATE.sql

# 7일 이상 된 파일 삭제
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
```

---

## 서버 적용 방법

### App Server

```bash
# 1. 스크립트 복사
mkdir -p ~/scripts
cp app-server/*.sh ~/scripts/

# 2. 실행 권한 부여
chmod +x ~/scripts/*.sh

# 3. 로그 폴더 생성
mkdir -p ~/logs

# 4. cron 등록 (선택)
crontab -e
# 매일 09:00 헬스체크
0 9 * * * ~/scripts/healthcheck.sh
# 매주 일요일 03:00 정리
0 3 * * 0 ~/scripts/weekly-cleanup.sh >> ~/logs/cleanup.log 2>&1
```

### GPU Server

```bash
# 1. 스크립트 복사 (root 권한)
sudo cp gpu-server/backup-db.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/backup-db.sh

# 2. 환경변수 파일 생성
sudo vi /etc/backup-db.env
# DB_PASSWORD=your-password-here

# 3. 백업 폴더 생성
sudo mkdir -p /var/backups/postgresql

# 4. cron 등록 (root)
sudo crontab -e
# 평일 08:00 백업
0 8 * * 1-5 /usr/local/bin/backup-db.sh >> /var/log/db-backup.log 2>&1
```
