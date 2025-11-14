# Deployment Guide: Self-Hosted Supabase on Coolify

## Executive Summary

| Aspect | Difficulty | Time | Cost |
|--------|-----------|------|------|
| **Self-Hosted Supabase Setup** | 🟡 Medium | 30-45 min | Free (your hardware) |
| **Frontend Deployment** | 🟢 Easy | 15 min | Free (Coolify) |
| **Infrastructure** | ✅ Ready | ✅ You own it | $0/month |
| **Scaling** | ✅ Excellent | 5 vCPU, 16GB RAM | 100K+ users |

---

## 1. Architecture

### Deployment Topology

```
┌───────────────────────────────────────────────────┐
│  PRODUCTION TIER (on your Coolify instance)       │
├───────────────────────────────────────────────────┤
│                                                   │
│  absendo.artur.engineer                           │
│  (Frontend - React SPA in Docker Nginx)           │
│              ↓                                    │
│  supabase.prod.artur.engineer                     │
│  (Backend - Supabase Docker: API + PostgreSQL)    │
│                                                   │
└───────────────────────────────────────────────────┘

Optional: Development Tier
┌───────────────────────────────────────────────────┐
│  dev.absendo.artur.engineer (Frontend)            │
│  supabase.dev.artur.engineer (Backend)            │
└───────────────────────────────────────────────────┘

Local Development (Your Machine)
┌───────────────────────────────────────────────────┐
│  localhost:5173 (Frontend - npm run dev)          │
│  localhost:54321 (Backend - Supabase CLI local)   │
└───────────────────────────────────────────────────┘
```

### Architecture Components

**Frontend (Docker)**
- React 19 + TypeScript + Vite (built)
- Served by lightweight Node.js server
- Single Docker image for all environments
- Environment variables injected at build time

**Backend (Self-Hosted Supabase)**
- PostgreSQL 15+ database
- Supabase Auth API
- Real-time subscriptions
- REST API endpoints
- Docker containers on Coolify

**Key Insight:** The Supabase client code doesn't change - same API whether cloud or self-hosted!

---

## 2. Environment Variables

### Frontend (.env)
```env
# Self-hosted Supabase endpoints
VITE_SUPABASE_URL=https://db.yourdomain.com
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Where to Get These Values

After deploying Supabase:

1. **Access Admin Dashboard:**
   ```
   https://db.yourdomain.com:8000
   ```

2. **Navigate to Settings → API:**
   ```
   - Project URL → VITE_SUPABASE_URL
   - Anon Public Key → VITE_SUPABASE_ANON_KEY
   - Service Role Key → Keep secure (backend only)
   ```

3. **Update Your .env:**
   ```bash
   # Copy keys from Supabase dashboard
   VITE_SUPABASE_URL=https://db.yourdomain.com
   VITE_SUPABASE_ANON_KEY=your_anon_key_here
   ```

---

## 3. Deploy Self-Hosted Supabase

### Option A: Using Coolify UI (Recommended)

#### Step 1: Prepare Docker Compose
Save this as `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: '--encoding=UTF8 --locale=C'
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 10s
      timeout: 5s
      retries: 5

  supabase:
    image: supabase/supabase:latest
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      JWT_EXP: 3600
      ANON_KEY: ${ANON_KEY}
      SERVICE_ROLE_KEY: ${SERVICE_ROLE_KEY}
      API_URL: https://db.${DOMAIN}
      POSTGRES_HOST: postgres
      POSTGRES_PORT: 5432
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "8000:8000"
      - "5432:5432"
    volumes:
      - supabase_data:/var/lib/supabase/storage

volumes:
  postgres_data:
  supabase_data:
```

#### Step 2: In Coolify Dashboard
1. **Services → New Service → Docker Compose**
2. **Paste the compose file above**
3. **Set Environment Variables:**

```
POSTGRES_PASSWORD=<generate-secure-password>
JWT_SECRET=<generate-32-char-string>
ANON_KEY=<see-below>
SERVICE_ROLE_KEY=<see-below>
DOMAIN=yourdomain.com
```

**How to generate keys:**
```bash
# Generate random strings
openssl rand -base64 32  # For POSTGRES_PASSWORD
openssl rand -base64 32  # For JWT_SECRET

# For JWT keys, use sample values or generate proper JWT tokens
```

#### Step 3: Configure Domain
1. **In Coolify:** Set domain to `db.yourdomain.com`
2. **Enable SSL** (automatic with Let's Encrypt)
3. **Update DNS:** Point `db.yourdomain.com` to your server IP

#### Step 4: Deploy
1. Click **Deploy**
2. Wait for containers to start (~2-3 minutes)
3. Access: `https://db.yourdomain.com:8000`

---

## 4. Initial Supabase Configuration

### Access Admin Console
```
URL: https://db.yourdomain.com:8000
Email: admin@supabase.io
Password: Set in environment or default
```

### Create Database Tables
Create tables matching your Supabase cloud schema:

```sql
-- Profiles table (for users & encryption)
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  email TEXT,
  first_name TEXT,
  last_name TEXT,
  birthday TEXT,
  phone_number_trainer TEXT,
  email_trainer TEXT,
  first_name_trainer TEXT,
  last_name_trainer TEXT,
  calendar_url TEXT,
  encryption_salt TEXT,
  pin_hash TEXT,
  has_pin BOOLEAN DEFAULT false,
  onboarding_completed BOOLEAN DEFAULT false
);

-- Absences table
CREATE TABLE absences (
  id SERIAL PRIMARY KEY,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  reason TEXT,
  is_excused BOOLEAN DEFAULT false,
  file_name TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Get API Keys
1. **Settings → API**
2. **Copy:**
   - Project URL
   - Anon Public Key
   - Service Role Key

---

## 5. Deploy Frontend

### Option A: Deploy to Coolify

1. **Coolify → Applications → New**
2. **Select GitHub repository** (absendo)
3. **Build command:** `npm run build`
4. **Start command:** `npm run preview` or use static hosting
5. **Environment variables:** Add your `.env` values
6. **Deploy**

### Option B: Keep on Vercel
Just update environment variables:

```bash
# In Vercel dashboard:
VITE_SUPABASE_URL=https://db.yourdomain.com
VITE_SUPABASE_ANON_KEY=your_anon_key
```

Then redeploy.

---

## 6. Database Migration (If Migrating from Cloud)

### Export from Supabase Cloud
```bash
# Export all data from cloud Supabase
pg_dump -h db.supabase.co -U postgres -d postgres > backup.sql
```

### Import to Self-Hosted
```bash
# Import to your self-hosted instance
psql -h localhost -U postgres -d postgres < backup.sql
```

**Note:** Encryption keys and salts in the database should transfer perfectly since they're just strings.

---

## 7. Backup Strategy

### Automatic Backups with Coolify
1. **Services → [Supabase] → Backups**
2. **Enable automatic backups**
3. **Schedule:** Daily at 2 AM UTC

### Manual Backup
```bash
docker exec absendo-postgres-1 pg_dump -U postgres postgres > backup-$(date +%Y%m%d).sql
```

---

## 8. Troubleshooting

### Supabase Not Starting
```bash
# Check logs
docker logs absendo-supabase-1

# Common fixes:
# - Ensure POSTGRES_PASSWORD is set
# - Check disk space (50GB recommended minimum)
# - Verify JWT_SECRET length (32+ chars)
```

### Connection Issues
```bash
# Test PostgreSQL connection
psql -h db.yourdomain.com -U postgres -d postgres

# Test Supabase API
curl https://db.yourdomain.com/rest/v1/
```

### Slow Performance
- Monitor CPU/RAM in Coolify
- Your 5 vCPU, 16GB RAM can handle 100K+ users
- Consider PostgreSQL tuning if needed

---

## 9. Maintenance

### Regular Tasks
- **Weekly:** Monitor disk usage
- **Monthly:** Review Supabase logs
- **Quarterly:** Update Docker images
  ```bash
  docker pull postgres:15-alpine
  docker pull supabase/supabase:latest
  ```

### Updates
In Coolify:
1. **Services → [Supabase]**
2. **Edit → Update Docker images**
3. **Redeploy**

---

## 10. Cost Comparison

| Item | Cloud Supabase | Self-Hosted |
|------|---|---|
| Auth | $0 (free tier) | $0 |
| Database | $25-100/mo | $0 |
| Storage | $5-10/mo | $0 |
| Hosting | $0 (SPA) | $0 (your hardware) |
| **Total** | **$30-110/mo** | **$0/mo** |

**Savings:** $30-110 per month by self-hosting on your hardware!

---

## 11. Configuration Checklist

- [ ] Generate secure passwords (POSTGRES_PASSWORD)
- [ ] Generate JWT_SECRET (32+ chars)
- [ ] Deploy Supabase on Coolify
- [ ] Configure domain (db.yourdomain.com)
- [ ] Access admin console at :8000
- [ ] Retrieve API keys from Settings → API
- [ ] Update frontend .env with keys
- [ ] Redeploy frontend
- [ ] Test login/signup functionality
- [ ] Set up automated backups
- [ ] Configure DNS for domain

---

## Next Steps

1. **Test everything locally first** (optional docker-compose)
2. **Deploy to Coolify** (30 min)
3. **Update frontend .env** (5 min)
4. **Verify encryption** (works identical to cloud)
5. **Monitor first week** for any issues
6. **Set up backups** for safety

Your infrastructure is more than capable - enjoy full data ownership! 🚀
