# 🌐 Nginx 구성

> MovieSir 프로젝트에서 사용한 실제 Nginx 설정 파일입니다.

<br />

## 소개

MovieSir는 **4개의 서브도메인**으로 서비스를 분리하여 운영합니다.

**Landing** (moviesir.cloud) - 서비스 소개 페이지<br />
**Demo App** (demo.moviesir.cloud) - B2C 영화 추천 앱<br />
**Console** (console.moviesir.cloud) - B2B 관리 콘솔<br />
**API** (api.moviesir.cloud) - API 소개 페이지

**분리한 이유:**
- **역할 분리** - 각 서비스별 독립적인 설정 관리
- **보안** - 서비스별 접근 제어 가능
- **캐싱 정책** - 정적 파일과 API 요청 구분

---

## 주요 설정 설명

### SSL/TLS 설정

Let's Encrypt 인증서를 사용하여 HTTPS를 적용합니다.

```nginx
ssl_certificate /etc/letsencrypt/live/moviesir.cloud/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/moviesir.cloud/privkey.pem;
include /etc/nginx/snippets/ssl-params.conf;
```

<br />

### SPA 라우팅

React SPA의 클라이언트 사이드 라우팅을 지원합니다.

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

<br />

### API 프록시

Backend (FastAPI :8000)로 요청을 프록시합니다.

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

<br />

### 캐싱 정책

배포 즉시 반영을 위해 index.html은 캐시하지 않고, 정적 파일은 1년 캐시합니다.

```nginx
# index.html - 캐시 안 함
location = /index.html {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}

# 정적 파일 - 1년 캐시
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 파일 구성

### [moviesir.conf](./moviesir.conf)

메인 Nginx 설정 파일입니다.

```bash
# 서버 적용 경로
/etc/nginx/sites-available/moviesir
```

| 서버 블록 | 도메인 | Root | 용도 |
|-----------|--------|------|------|
| HTTP :80 | 전체 | - | HTTPS 리다이렉트 |
| HTTPS :443 | moviesir.cloud | `/var/www/landing` | 랜딩 페이지 |
| HTTPS :443 | demo.moviesir.cloud | `/var/www/demo` | B2C Demo App |
| HTTPS :443 | console.moviesir.cloud | `/var/www/console` | B2B Console |
| HTTPS :443 | api.moviesir.cloud | `/var/www/api` | API 소개 페이지 |

---

### [ssl-params.conf](./ssl-params.conf)

SSL 보안 설정 파일입니다.

```bash
# 서버 적용 경로
/etc/nginx/snippets/ssl-params.conf
```

- **TLS 버전** - TLS 1.2, 1.3만 허용
- **Cipher Suites** - 강력한 암호화 알고리즘만 사용
- **HSTS** - 2년간 HTTPS 강제

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;
add_header Strict-Transport-Security "max-age=63072000" always;
```

---

## 서버 적용 방법

```bash
# 1. 설정 파일 복사
sudo cp moviesir.conf /etc/nginx/sites-available/moviesir
sudo cp ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# 2. 심볼릭 링크 생성
sudo ln -sf /etc/nginx/sites-available/moviesir /etc/nginx/sites-enabled/

# 3. 기본 설정 제거
sudo rm -f /etc/nginx/sites-enabled/default

# 4. 설정 테스트 및 적용
sudo nginx -t && sudo systemctl reload nginx
```

---

## SSL 인증서 발급 (Let's Encrypt)

```bash
sudo certbot --nginx \
  -d moviesir.cloud \
  -d www.moviesir.cloud \
  -d demo.moviesir.cloud \
  -d console.moviesir.cloud \
  -d api.moviesir.cloud
```
