# Deployment Guide: Absendo on Coolify

> **Hosting:** cloud.artur.engineer (Coolify)  
> **Deployment:** Automatic via GitHub webhook on push  
> **Stack:** React 19 + Vite + TypeScript (Static SPA with Nginx)

## Prerequisites

- Coolify instance accessible at `cloud.artur.engineer`
- GitHub repository connected to Coolify
- Supabase instance running (production: `supabase.prod.artur.engineer`)
- Domain configured: `absendo.artur.engineer`

---

## 1. Coolify Resource Configuration

### Create New Application

**Navigation:** Project → Environment → Add Resource → Application

**Basic Settings:**

| Setting | Value |
|---------|-------|
| **Build Pack** | Dockerfile |
| **Dockerfile Location** | `./Dockerfile` |
| **Base Directory** | `/` |
| **Ports Exposes** | `80` |
| **Health Check Path** | `/health` |
| **Health Check Port** | `80` |
| **Health Check Interval** | `30s` |
| **Health Check Timeout** | `3s` |
| **Health Check Retries** | `3` |

---

## 2. Environment Variables

Copy these environment variables from `.env.example` into Coolify's environment variable settings.

### Required Variables

```bash
# Supabase Connection (CRITICAL - app won't work without these)
VITE_SUPABASE_URL=https://supabase.prod.artur.engineer
VITE_SUPABASE_ANON_KEY=your_production_anon_key_here
```

**How to get Supabase credentials:**

1. Access Supabase dashboard at `https://supabase.prod.artur.engineer`
2. Navigate to **Settings → API**
3. Copy:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **Anon Public Key** → `VITE_SUPABASE_ANON_KEY`

### Optional Variables

```bash
# Build configuration
NODE_ENV=production
VITE_BUILD_OUTPUT=dist
```

---

## 3. Domain Configuration

### Primary Domain

Set in Coolify application settings:

```
absendo.artur.engineer
```

### SSL Certificate

- **Type:** Automatic (Let's Encrypt)
- **Status:** Enabled by default in Coolify
- **Renewal:** Automatic

### DNS Configuration (if not already done)

Add an A record in your DNS provider:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | absendo | [Your Server IP] | 300 |

---

## 4. Webhook Setup (Automatic Deployment)

### GitHub Integration

Coolify automatically configures webhooks when you connect a GitHub repository.

**Deployment Trigger:**
- Push to `main` branch → Automatic deployment
- Pull request merge → Automatic deployment

### Manual Deployment

If you need to trigger a deployment manually:

1. Go to Coolify Dashboard
2. Navigate to **Applications → Absendo**
3. Click **Deploy** button

---

## 5. Resource Limits (Recommended)

Configure resource limits in Coolify to ensure efficient resource usage:

```yaml
Memory Limit: 512M
Memory Reservation: 256M
CPU Limit: 0.5 cores
CPU Reservation: 0.25 cores
```

**Why these limits:**
- Static React SPA has minimal resource needs
- Nginx is extremely lightweight
- Prevents resource hogging on shared infrastructure

---

## 6. Health Check & Monitoring

### Health Check Endpoint

The application includes a built-in health check endpoint:

```bash
# Health check URL
https://absendo.artur.engineer/health

# Expected response
{
  "status": "ok",
  "service": "absendo"
}
```

### Monitoring in Coolify

1. **Application Dashboard:** Real-time status indicator
2. **Logs:** Coolify Dashboard → Applications → Absendo → Logs
3. **Metrics:** Built-in CPU, Memory, Network usage graphs

### Health Check Configuration

Already configured in Dockerfile:
- **Interval:** 30s
- **Timeout:** 3s
- **Start Period:** 5s
- **Retries:** 3

---

## 7. Troubleshooting

### Build Failures

**Check build logs:**
```bash
# In Coolify: Applications → Absendo → Deployment Logs
```

**Common issues:**
- Missing environment variables → Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
- TypeScript errors → Run `npm run build` locally first
- Out of memory → Increase memory limit in Coolify

### Health Check Failing

**Symptoms:** Application shows as unhealthy in Coolify

**Solutions:**
1. Verify `/health` endpoint is accessible:
   ```bash
   curl https://absendo.artur.engineer/health
   ```
2. Check container logs for errors
3. Ensure port 80 is exposed in Dockerfile
4. Verify Nginx is running inside container

### Application Not Accessible

**Check DNS:**
```bash
nslookup absendo.artur.engineer
# Should resolve to your server IP
```

**Check SSL:**
```bash
curl -I https://absendo.artur.engineer
# Should return 200 OK
```

**Check container status:**
```bash
docker ps | grep absendo
# Container should be in "healthy" state
```

### Supabase Connection Errors

**Symptoms:** Login/signup not working

**Solutions:**
1. Verify `VITE_SUPABASE_URL` is correct
2. Test Supabase endpoint:
   ```bash
   curl https://supabase.prod.artur.engineer/rest/v1/
   ```
3. Check browser console for CORS errors
4. Verify Supabase container is running

---

## 8. Testing Deployment

### Local Testing (Before Pushing to GitHub)

Test the Docker build locally:

```bash
# 1. Build the Docker image
docker build -t absendo-test .

# 2. Run the container
docker run -p 8080:80 \
  -e VITE_SUPABASE_URL=https://supabase.prod.artur.engineer \
  -e VITE_SUPABASE_ANON_KEY=your_anon_key \
  absendo-test

# 3. Test health check
curl http://localhost:8080/health

# 4. Test application
open http://localhost:8080
```

### Post-Deployment Verification

After deploying to Coolify:

1. **Health Check:**
   ```bash
   curl https://absendo.artur.engineer/health
   # Expected: {"status":"ok","service":"absendo"}
   ```

2. **Application Load:**
   ```bash
   curl -I https://absendo.artur.engineer
   # Expected: HTTP/2 200
   ```

3. **Functional Test:**
   - Open `https://absendo.artur.engineer`
   - Test login/signup flow
   - Verify calendar integration
   - Generate a test PDF

---

## 9. Deployment Checklist

Use this checklist when deploying:

- [ ] **Prerequisites**
  - [ ] Coolify instance accessible
  - [ ] GitHub repository connected
  - [ ] Supabase instance running
  - [ ] Domain DNS configured

- [ ] **Coolify Configuration**
  - [ ] Build Pack set to "Dockerfile"
  - [ ] Ports Exposes set to "80"
  - [ ] Health Check Path set to "/health"
  - [ ] Domain configured: `absendo.artur.engineer`

- [ ] **Environment Variables**
  - [ ] `VITE_SUPABASE_URL` set
  - [ ] `VITE_SUPABASE_ANON_KEY` set
  - [ ] `NODE_ENV=production` set

- [ ] **Testing**
  - [ ] Docker build tested locally
  - [ ] Health endpoint responding
  - [ ] Application loads correctly
  - [ ] Login/signup working
  - [ ] Calendar integration functional

- [ ] **Monitoring**
  - [ ] Health checks enabled
  - [ ] SSL certificate active
  - [ ] Logs accessible in Coolify
  - [ ] Resource limits configured

---

## 10. Quick Reference

### Deployment URLs

| Service | URL |
|---------|-----|
| **Production App** | https://absendo.artur.engineer |
| **Health Check** | https://absendo.artur.engineer/health |
| **Supabase API** | https://supabase.prod.artur.engineer |
| **Coolify Dashboard** | https://cloud.artur.engineer |

### Key Commands

```bash
# Test local Docker build
docker build -t absendo-test .

# Run container locally
docker run -p 8080:80 --env-file .env absendo-test

# Check health
curl http://localhost:8080/health

# View Coolify logs (on server)
docker logs [container-name]

# Manual deployment
# Use Coolify UI → Deploy button
```

### Environment Variables Quick Copy

```bash
# Production
VITE_SUPABASE_URL=https://supabase.prod.artur.engineer
VITE_SUPABASE_ANON_KEY=[get-from-supabase-dashboard]
NODE_ENV=production
```

### Support Resources

- **Coolify Docs:** https://coolify.io/docs
- **Nginx Docs:** https://nginx.org/en/docs/
- **Supabase Docs:** https://supabase.com/docs
- **Repository:** https://github.com/artur/absendo

---

**Last Updated:** 2025-11-14  
**Coolify Version:** 4.x  
**Docker Version:** 24.x+
