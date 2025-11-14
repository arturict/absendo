# Docker & Multi-Environment Deployment Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      YOUR HARDWARE                          │
│              (5 vCPU, 16GB RAM on Coolify)                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PRODUCTION TIER                                            │
│  ├─ absendo.artur.engineer (Frontend - Docker Nginx)       │
│  │  └─ Runs: npm run build output via serve                │
│  └─ supabase.prod.artur.engineer (Backend - Supabase)      │
│     ├─ Supabase API Server                                 │
│     ├─ PostgreSQL 15                                       │
│     └─ Auth Service                                        │
│                                                             │
│  DEVELOPMENT TIER (Optional)                               │
│  ├─ dev.absendo.artur.engineer (Frontend - Optional)       │
│  └─ supabase.dev.artur.engineer (Backend - Optional)       │
│                                                             │
│  LOCAL DEVELOPMENT (Your Machine)                          │
│  ├─ localhost:5173 (Frontend - npm run dev)                │
│  └─ localhost:54321 (Backend - Supabase CLI local)         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 1. File Structure

```
absendo/
├── Dockerfile                    ← NEW: Frontend Docker image
├── .dockerignore                 ← NEW: Docker build excludes
├── docker-compose.local.yml      ← NEW: Local dev environment
├── .env.example                  ← NEW: Example env template
├── .env.production               ← NEW: Prod environment
├── .env.development              ← NEW: Dev environment (optional)
├── .env.local                    ← NEW: Local environment
├── DEPLOYMENT.md                 ← Supabase setup
├── DOCKER.md                     ← NEW: Docker & deployment guide (THIS FILE)
├── README.md
├── QUICKSTART.md
├── package.json
├── vite.config.ts
├── tsconfig.json
├── src/
│   ├── supabaseClient.ts         ← Uses VITE_SUPABASE_URL
│   └── ...
└── ...
```

## 2. Frontend Dockerfile Explained

```dockerfile
# Multi-stage build = smaller final image

# Stage 1: BUILD
FROM node:18-alpine as builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci                          # Clean install (reproducible)
COPY . .
RUN npm run build                   # Creates /app/dist

# Stage 2: PRODUCTION
FROM node:18-alpine as production
WORKDIR /app
RUN npm install -g serve            # Lightweight HTTP server
COPY --from=builder /app/dist ./dist
EXPOSE 3000
```

**Result:** ~100-150MB image (Node 18 minimal + built app)

## 3. Environment Variables Strategy

### File Structure

```
.env.example         ← Template (commit to git)
.env.local          ← Local dev (GITIGNORED)
.env.production     ← Production (GITIGNORED, used by Coolify)
.env.development    ← Dev tier (GITIGNORED, if using)
```

### How Environment Variables Are Used

**In Frontend Code:**
```typescript
// src/supabaseClient.ts
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
```

**Build Time vs Runtime:**
- Vite replaces `import.meta.env` at **build time**
- Different Docker images for different environments needed? **Yes**
- This means: build frontend inside Docker with correct env

## 4. Multi-Environment Setup

### Production Deployment

```yaml
# In Coolify Dashboard:
# 1. Create Application
# - Repository: your-absendo-repo
# - Dockerfile: Dockerfile
# - Build command: (default - uses Dockerfile)
# - Start command: (default - from Dockerfile ENTRYPOINT)
# - Ports: 3000
# - Domain: absendo.artur.engineer
# - SSL: Enable (Let's Encrypt)
# 
# 2. Environment Variables
# - VITE_SUPABASE_URL=https://supabase.prod.artur.engineer
# - VITE_SUPABASE_ANON_KEY=<production-anon-key>
#
# 3. Deploy
```

**Flow:**
```
Coolify sees Dockerfile
  ↓
Runs: npm install
  ↓
Runs: npm run build
  ↓
Creates production image
  ↓
Starts container on port 3000
  ↓
Accessible at absendo.artur.engineer
```

### Development Deployment (Optional)

```bash
# If you want a separate dev environment:
# In Coolify Dashboard:
# - Repository: same repo, branch: dev
# - Domain: dev.absendo.artur.engineer
# - Environment: VITE_SUPABASE_URL=https://supabase.dev.artur.engineer
```

### Local Development

```bash
# Terminal 1: Frontend (Hot reload)
npm run dev
# → http://localhost:5173

# Terminal 2: Supabase (if using local)
supabase start
# → http://localhost:54321
```

## 5. Building Docker Images Locally

### Build Production Image

```bash
# Build with production env
docker build -t absendo:prod \
  --build-arg VITE_SUPABASE_URL=https://supabase.prod.artur.engineer \
  --build-arg VITE_SUPABASE_ANON_KEY=your_anon_key \
  .
```

### Run Locally

```bash
docker run -p 3000:3000 \
  -e VITE_SUPABASE_URL=https://supabase.prod.artur.engineer \
  -e VITE_SUPABASE_ANON_KEY=your_anon_key \
  absendo:prod
```

**Note:** For Vite, env vars need to be set at **build time**, not runtime. To change env, rebuild the image.

## 6. Docker Compose for Local Development

```yaml
# docker-compose.local.yml
# Run everything locally for testing

version: '3.8'

services:
  supabase:
    image: supabase/supabase:latest
    environment:
      POSTGRES_PASSWORD: postgres
      JWT_SECRET: your-jwt-secret-32-chars-min
      API_URL: http://localhost:54321
      POSTGRES_HOST: postgres
      POSTGRES_PORT: 5432
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
    ports:
      - "54321:8000"  # API
      - "5432:5432"   # PostgreSQL
    volumes:
      - supabase_data:/var/lib/supabase/storage

  frontend:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      VITE_SUPABASE_URL: http://localhost:54321
      VITE_SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    ports:
      - "3000:3000"
    depends_on:
      - supabase

volumes:
  supabase_data:
```

**Run it:**
```bash
docker-compose -f docker-compose.local.yml up
```

## 7. Deployment Workflow

### First Time Setup

```
┌─────────────────────────────────────────────┐
│ 1. Generate Supabase Passwords              │
│    (POSTGRES_PASSWORD, JWT_SECRET)          │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. Deploy Supabase on Coolify               │
│    - Service: supabase.prod.artur.engineer  │
│    - Backend: PostgreSQL + Auth API         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. Get Supabase API Keys                    │
│    - From: supabase.prod.artur.engineer:8000│
│    - Settings → API                         │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 4. Deploy Frontend on Coolify               │
│    - Application: absendo.artur.engineer    │
│    - Dockerfile: (auto-detected)            │
│    - Env: VITE_SUPABASE_URL, ANON_KEY      │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 5. Test                                     │
│    - Visit: absendo.artur.engineer          │
│    - Login/signup                           │
│    - Verify encryption works                │
└─────────────────────────────────────────────┘
```

### Update Flow (After Code Changes)

```
Push to main branch
    ↓
Coolify detects new commit
    ↓
Pulls latest code
    ↓
Runs: npm ci
    ↓
Runs: npm run build
    ↓
Docker image built with current env vars
    ↓
Old container stopped
    ↓
New container started
    ↓
Site redeployed (0 downtime with Coolify)
```

## 8. Environment Variables Per Environment

### Local (.env.local)

```env
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=local_key_here
```

**Usage:**
```bash
npm run dev
# Automatically loads .env.local
```

### Development (Optional .env.development)

```env
VITE_SUPABASE_URL=https://supabase.dev.artur.engineer
VITE_SUPABASE_ANON_KEY=dev_key_here
```

**In Coolify:** Set same env vars when deploying dev branch

### Production (.env.production)

```env
VITE_SUPABASE_URL=https://supabase.prod.artur.engineer
VITE_SUPABASE_ANON_KEY=prod_key_here
```

**In Coolify:** Set same env vars when deploying main branch

## 9. Commands Reference

### Development

```bash
# Install
npm install

# Local dev with Supabase
npm run dev                    # Frontend on :5173
supabase start                 # Backend on :54321

# Build locally
npm run build

# Lint
npm run lint

# Preview built app
npm run preview
```

### Docker Locally

```bash
# Build image
docker build -t absendo:latest .

# Run container
docker run -p 3000:3000 absendo:latest

# Build with specific env
docker build -t absendo:prod \
  --build-arg VITE_SUPABASE_URL=https://supabase.prod.artur.engineer \
  .

# Docker Compose (local full stack)
docker-compose -f docker-compose.local.yml up
docker-compose -f docker-compose.local.yml down
```

### Coolify Deployment

```
1. In Coolify Dashboard
2. Applications → Add
3. Select: Dockerfile from Git
4. Repository: your repo
5. Dockerfile: Dockerfile (default)
6. Environment: Set VITE_* variables
7. Deploy
```

## 10. Troubleshooting

### Frontend can't connect to Supabase

```bash
# Check env vars in Coolify
# Settings → Deployment → Environment Variables

# Verify URL is correct
curl https://supabase.prod.artur.engineer/rest/v1/

# Check frontend logs in Coolify
# Deployment → Logs → View
```

### Build fails

```bash
# Check build logs in Coolify
# Ensure npm ci succeeds
# Ensure npm run build succeeds locally first

docker build -t absendo . 2>&1 | tail -50
```

### Slow builds

```bash
# Keep it cached between builds
# Docker automatically caches layers
# First build: slow (installs node_modules)
# Subsequent builds: fast (cached layers)
```

## 11. Image Size Optimization

Current Dockerfile produces ~120-150MB production image

To make even smaller:

```dockerfile
# Use alpine base
FROM node:18-alpine
# Result: ~50MB smaller images
```

**Already optimized in provided Dockerfile ✓**

## 12. Deployment Checklist

- [ ] Generate Supabase passwords (POSTGRES_PASSWORD, JWT_SECRET)
- [ ] Deploy Supabase service on Coolify
- [ ] Configure domain: supabase.prod.artur.engineer
- [ ] Get Supabase API keys from Settings → API
- [ ] Create .env.production with keys
- [ ] Deploy Frontend app on Coolify from Dockerfile
- [ ] Configure domain: absendo.artur.engineer
- [ ] Set Frontend env vars in Coolify
- [ ] Test login at absendo.artur.engineer
- [ ] Test encryption flow
- [ ] Configure automated backups for Supabase
- [ ] Set up monitoring/alerts

## 13. Multi-Environment Summary

| Item | Local | Dev | Production |
|------|-------|-----|-----------|
| **Frontend URL** | localhost:5173 | dev.absendo.artur.engineer | absendo.artur.engineer |
| **Backend URL** | localhost:54321 | supabase.dev.artur.engineer | supabase.prod.artur.engineer |
| **Deployment** | npm run dev | Coolify Docker | Coolify Docker |
| **Database** | Docker local | Coolify Docker | Coolify Docker |
| **SSL** | No | Yes (Let's Encrypt) | Yes (Let's Encrypt) |
| **Code Updates** | Manual (npm run dev) | Git push to dev branch | Git push to main branch |

## Next Steps

1. ✅ You have Dockerfile ready
2. ✅ You have .env files ready
3. Next: Deploy Supabase first (see DEPLOYMENT.md)
4. Then: Deploy Frontend with Docker (Coolify will auto-build)
5. Test: Visit absendo.artur.engineer
6. Monitor: Logs in Coolify dashboard

That's it! Full multi-environment setup with Docker. 🚀
