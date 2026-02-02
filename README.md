# 🎬 MovieSir Infrastructure

> AI 기반 영화 추천 서비스 MovieSir의 인프라 구성입니다.

<br />

## 프로젝트 소개

MovieSir는 **2-Tier 아키텍처**로 구성된 영화 추천 서비스입니다.

| 서버           | 역할      | 구성                           |
| -------------- | --------- | ------------------------------ |
| **App Server** | 웹 서비스 | Nginx + Backend + Redis        |
| **GPU Server** | AI 추천   | PostgreSQL + AI Service (CUDA) |

<br />

## 아키텍처

![MovieSir Infrastructure Architecture](./docs/moviesir_infra_arch.drawio.png)

<br />

## 기술 스택

| 분류           | 기술                           |
| -------------- | ------------------------------ |
| **Container**  | Docker, Docker Compose         |
| **Web Server** | Nginx (SSL/TLS, Reverse Proxy) |
| **CI/CD**      | GitHub Actions                 |
| **Cloud**      | KakaoCloud VPC                 |
| **Database**   | PostgreSQL 16 + pgvector       |
| **Cache**      | Redis                          |
| **GPU**        | NVIDIA Tesla T4 (CUDA)         |

<br />

## 폴더 구조

```
MovieSir-Infra/
├── docker/                    # Docker Compose 구성
│   ├── docker-compose.yml         # App Server (Production)
│   ├── docker-compose.gpu.yml     # GPU Server (Production)
│   ├── docker-compose.local.yml   # Local Development
│   └── README.md
│
├── cicd/                      # GitHub Actions 워크플로우
│   ├── deploy-frontend.yml        # Frontend 배포
│   ├── deploy-backend.yml         # Backend 배포
│   ├── deploy-gpu.yml             # GPU Server 배포
│   └── README.md
│
├── nginx/                     # Nginx 설정
│   ├── moviesir.conf              # 4개 서브도메인 서버 블록
│   ├── ssl-params.conf            # TLS 1.2/1.3 보안 설정
│   └── README.md
│
├── scripts/                   # 서버 자동화 스크립트
│   ├── app-server/                # App Server 스크립트
│   │   ├── disk-alert.sh              # 디스크 사용률 모니터링
│   │   ├── healthcheck.sh             # 서버 상태 점검
│   │   └── weekly-cleanup.sh          # 주간 정리
│   ├── gpu-server/                # GPU Server 스크립트
│   │   └── backup-db.sh               # PostgreSQL 자동 백업
│   └── README.md
│
├── docs/                      # 문서 및 이미지
│   └── moviesir_infra_arch.drawio.png
│
└── README.md                  # 현재 문서
```

<br />

## 문서

| 문서                                           | 설명                       |
| ---------------------------------------------- | -------------------------- |
| [Docker Compose 구성](./docker/README.md)      | 서버별 Docker Compose 설정 |
| [GitHub Actions CI/CD](./cicd/README.md)       | 자동 배포 워크플로우       |
| [Nginx 설정](./nginx/README.md)                | 서브도메인 및 SSL 설정     |
| [서버 자동화 스크립트](./scripts/README.md)    | 모니터링, 백업, 정리 스크립트 |

<br />

## 주요 특징

### 서버 분리

- App Server와 GPU Server를 독립적으로 운영
- 각 서버별 독립 배포 가능
- 장애 격리로 안정성 확보

### 자동 배포

- Path 기반 트리거로 변경된 부분만 배포
- CI(빌드/테스트) 성공 시에만 CD(배포) 실행
- ProxyJump로 Private Subnet GPU 서버 접근

### 환경 분리

- Production / Local 환경별 설정 분리
- GitHub Secrets로 민감 정보 관리
- `.env` 파일로 환경변수 관리
