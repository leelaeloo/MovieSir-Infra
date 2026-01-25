# 🐳 Docker Compose 구성

> MovieSir 프로젝트에서 사용한 실제 Docker Compose 파일입니다.

<br />

## 소개

MovieSir는 **2-Tier 아키텍처**로 구성되어 있습니다.

**App Server**에서는 Backend와 Redis가 동작하고,<br />
**GPU Server**에서는 AI 추천 서비스와 PostgreSQL이 동작합니다.

각 서버별로 docker-compose 파일을 분리하여 독립적으로 배포할 수 있도록 구성했습니다.

<br />

## 파일 구성

### docker-compose.yml

App Server 프로덕션 환경입니다.

```bash
docker compose --env-file .env.production up -d --build
```

- **backend** (`:8000`) - FastAPI 백엔드
- **redis** (`:6379`) - 세션/캐시/Rate Limiting
- **dozzle** (`:9999`) - 로그 모니터링 UI

<br />

### docker-compose.gpu.yml

GPU Server 프로덕션 환경입니다.

```bash
docker compose -f docker-compose.gpu.yml --env-file .env.production up -d --build
```

- **ai** (`:8001`) - AI 추천 서비스 (CUDA)
- **dozzle** (`:9999`) - 로그 모니터링 UI

<br />

### docker-compose.local.yml

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
