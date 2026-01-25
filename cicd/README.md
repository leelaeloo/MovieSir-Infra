# 🚀 GitHub Actions CI/CD

> MovieSir 프로젝트에서 사용한 실제 GitHub Actions 워크플로우입니다.

<br />

## 소개

MovieSir는 **서버별로 독립적인 배포 파이프라인**을 구성했습니다.

**App Server**에서는 Frontend와 Backend가 배포되고,<br />
**GPU Server**에서는 AI 서비스가 배포됩니다.

**분리한 이유:**
- **독립적인 배포** - Frontend/Backend/AI 각각 따로 배포 가능
- **빠른 배포** - 변경된 부분만 배포하여 시간 단축
- **비용 절감** - 불필요한 GPU 서버 재배포 방지

---

## 주요 설정 설명

### Path 기반 트리거

변경된 파일 경로에 따라 워크플로우가 자동 실행됩니다.

```yaml
on:
  push:
    branches: [dev, main]
    paths:
      - 'frontend/**'      # frontend 폴더 변경 시
      - 'frontend-console/**'
```

<br />

### CI/CD 분리

CI(빌드/테스트)가 성공해야 CD(배포)가 실행됩니다.

```yaml
jobs:
  ci:
    runs-on: ubuntu-latest
    name: TypeCheck & Build
    # 빌드 및 문법 체크

  deploy:
    needs: ci              # ci job 성공 후 실행
    if: github.event_name == 'push'
    # 배포 스크립트
```

<br />

### ProxyJump (GPU 서버)

GPU 서버는 Private Subnet에 있어 App Server를 경유해서 접속합니다.

```yaml
- name: Deploy to GPU Server via SSH
  uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.GPU_PRIVATE_IP }}
    proxy_host: ${{ secrets.APP_HOST }}
    proxy_port: 52222
```

<br />

### GitHub Secrets

민감한 정보는 GitHub Secrets로 관리합니다.

```yaml
${{ secrets.APP_HOST }}           # App Server IP
${{ secrets.SSH_KEY }}            # SSH Private Key
${{ secrets.ENV_PRODUCTION_APP }} # 환경변수 파일 내용
```

---

## 파일 구성

### [deploy-frontend.yml](./deploy-frontend.yml)

Frontend 빌드 및 배포 워크플로우입니다.

```bash
# 트리거: frontend/**, frontend-console/** 변경 시
```

- **CI** - Node.js 20, npm ci, npm run build
- **CD** - SCP로 빌드 파일 전송 → Nginx 디렉토리로 이동

```yaml
- name: Deploy Demo App via SCP
  uses: appleboy/scp-action@v0.1.7
  with:
    source: "frontend/dist/*"
    target: "/tmp/frontend-build"
    strip_components: 2
```

---

### [deploy-backend.yml](./deploy-backend.yml)

Backend 빌드 및 배포 워크플로우입니다.

```bash
# 트리거: backend/**, docker-compose.yml, nginx/** 변경 시
```

- **CI** - Python 3.11, 문법 체크 (py_compile)
- **CD** - Docker Compose로 컨테이너 빌드 및 실행

```yaml
- name: Deploy Backend via SSH
  script: |
    docker compose --env-file .env.production down || true
    docker compose --env-file .env.production up -d --build backend redis dozzle
```

---

### [deploy-gpu.yml](./deploy-gpu.yml)

AI 서비스 GPU 서버 배포 워크플로우입니다.

```bash
# 트리거: ai/inference/**, ai/api.py, docker-compose.gpu.yml 변경 시
```

- **CI** - Python 3.11, 문법 체크
- **CD** - ProxyJump로 GPU 서버 접속 → Docker 빌드 및 실행

```yaml
- name: Deploy to GPU Server via SSH
  with:
    host: ${{ secrets.GPU_PRIVATE_IP }}
    proxy_host: ${{ secrets.APP_HOST }}    # Bastion Host
    proxy_port: 52222
```
