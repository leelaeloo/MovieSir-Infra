# 🐳 Docker Compose 구성

> MovieSir 프로젝트에서 사용한 실제 Docker Compose 파일입니다.

<br />

## 소개

MovieSir는 **2-Tier 아키텍처**로 구성되어 있습니다.

**App Server**에서는 Backend와 Redis가 동작하고,<br />
**GPU Server**에서는 AI 추천 서비스와 PostgreSQL이 동작합니다.

각 서버별로 docker-compose 파일을 분리하여 독립적으로 배포할 수 있도록 구성했습니다.

**분리한 이유:**
- **독립적인 배포** - App Server와 GPU Server를 따로 배포 가능
- **리소스 분리** - Backend 수정 시 GPU 서버 재배포 불필요 (비용 절감)
- **장애 격리** - AI 서비스 장애가 Backend에 영향 안 줌

---

## 주요 설정 설명

### Healthcheck

컨테이너 상태를 주기적으로 확인하여 장애를 감지합니다.

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/"]
  interval: 30s      # 30초마다 체크
  timeout: 10s       # 10초 내 응답 없으면 실패
  retries: 3         # 3회 실패 시 unhealthy
  start_period: 30s  # 컨테이너 시작 후 30초 대기
```

<br />

### 환경변수 분리

민감한 정보는 `.env` 파일로 분리하여 관리합니다.

```yaml
environment:
  - DATABASE_URL=${DATABASE_URL}
  - JWT_SECRET_KEY=${JWT_SECRET_KEY}
  - REDIS_URL=${REDIS_URL}
```

`.env.production`, `.env.local` 파일을 환경별로 구분하여 사용합니다.

---

## 파일 구성

### [docker-compose.yml](./docker-compose.yml)

App Server 프로덕션 환경입니다.

```bash
docker compose --env-file .env.production up -d --build
```

- **backend** (`:8000`) - FastAPI 백엔드
- **redis** (`:6379`) - 세션/캐시/Rate Limiting
- **dozzle** (`:9999`) - 로그 모니터링 UI

Backend 서비스는 Redis가 healthy 상태가 된 후에 시작됩니다.

```yaml
backend:
  depends_on:
    redis:
      condition: service_healthy
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8000/"]
    interval: 30s
    timeout: 10s
    retries: 3
```

---

### [docker-compose.gpu.yml](./docker-compose.gpu.yml)

GPU Server 프로덕션 환경입니다.

```bash
docker compose -f docker-compose.gpu.yml --env-file .env.production up -d --build
```

- **ai** (`:8001`) - AI 추천 서비스 (CUDA)
- **dozzle** (`:9999`) - 로그 모니터링 UI

AI 서비스는 NVIDIA GPU를 사용하며, `network_mode: host`로 PostgreSQL에 접근합니다.

```yaml
ai:
  deploy:
    resources:
      reservations:
        devices:
          - capabilities: [gpu]
  network_mode: host
```

---

### [docker-compose.local.yml](./docker-compose.local.yml)

로컬 개발 환경입니다. GPU 없이 전체 스택을 테스트할 수 있습니다.

```bash
docker compose -f docker-compose.local.yml --env-file .env.local up -d --build
```

- **frontend** (`:3000`) - React 프론트엔드
- **frontend-console** (`:3001`) - B2B 콘솔
- **backend** (`:8000`) - FastAPI 백엔드
- **ai** (`:8001`) - AI 서비스 (CPU 모드)
- **db** (`:5433`) - PostgreSQL + pgvector
- **redis** (`:6380`) - Redis
- **adminer** (`:8080`) - DB 관리 UI

AI 서비스는 `USE_GPU=false`로 CPU 모드로 빌드됩니다.

```yaml
ai:
  build:
    context: ./ai
    args:
      USE_GPU: "false"
```
