# Quick Reference: Self-Hosted Supabase Setup

## TL;DR

You're keeping Supabase architecture but hosting it yourself on your Coolify instance.

### The Change
```
Before: supabase.co (cloud)  →  After: db.yourdomain.com (self-hosted on your hardware)
```

**Good news:** No code changes needed! Supabase API stays identical.

---

## Required Environment Variables

### Frontend (.env)
```env
VITE_SUPABASE_URL=https://db.yourdomain.com
VITE_SUPABASE_ANON_KEY=<copy from Supabase Settings → API>
```

### Backend (for Coolify Supabase Docker)
```env
POSTGRES_PASSWORD=<generate: openssl rand -base64 32>
JWT_SECRET=<generate: openssl rand -base64 32>
ANON_KEY=<from Settings → API>
SERVICE_ROLE_KEY=<from Settings → API>
DOMAIN=yourdomain.com
```

---

## Setup Timeline

| Task | Time | Difficulty |
|------|------|-----------|
| Generate passwords | 2 min | ✅ Easy |
| Deploy Supabase on Coolify | 30 min | 🟡 Medium |
| Configure domain & SSL | 10 min | ✅ Easy |
| Retrieve API keys | 5 min | ✅ Easy |
| Update frontend .env | 5 min | ✅ Easy |
| Redeploy frontend | 10 min | ✅ Easy |
| Test & verify | 10 min | ✅ Easy |
| **Total** | **~72 min** | **🟡 Medium** |

---

## Key Files

| File | Purpose | Last Updated |
|------|---------|--------------|
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Complete setup guide + Docker Compose | Nov 12, 2025 |
| [README.md](./README.md) | Project overview + features | Nov 12, 2025 |
| [.github/copilot-instructions.md](./.github/copilot-instructions.md) | AI assistant guidance | Nov 12, 2025 |

---

## Why Self-Host?

| Aspect | Cloud | Self-Hosted |
|--------|-------|-------------|
| Cost | $25-100/mo | Free (your hardware) |
| Data Ownership | Supabase | You |
| Privacy | Shared servers | Isolated |
| Control | Limited | Full |
| Complexity | Simple | Medium |
| Uptime | 99.9% SLA | Your responsibility |

**Bottom line:** You save $300-1200/year and own all your data.

---

## Current Features ✅

- User auth (login/signup)
- End-to-end encryption (E2E)
- Calendar import (iCal)
- PDF form generation
- PIN protection
- User profiles
- Absence tracking
- Contact form

## Missing Features 🔜

- Batch export (CSV/Excel)
- Multi-language UI
- Advanced search
- Email notifications
- 2FA
- Admin dashboard

---

## Your Infrastructure

```
Machine:    5 vCPU, 16GB RAM ✅
Capacity:   100K+ users easily
Cost:       $0/month (you own it)
Uptime:     Your responsibility
```

**Perfect fit!** Your hardware is 10x overkill for Absendo's needs.

---

## Next Action

1. Read [DEPLOYMENT.md](./DEPLOYMENT.md)
2. Generate secure passwords
3. Deploy Supabase on Coolify
4. Update `.env` files
5. Redeploy frontend
6. Test login flow

That's it! You're self-hosted. 🚀
