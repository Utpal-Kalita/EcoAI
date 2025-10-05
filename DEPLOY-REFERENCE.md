# 🚀 EcoAI Deployment Quick Reference

## Three Service Architecture

```
Frontend (Next.js)  →  Backend (Node.js)  →  AI Service (Python)
    Vercel                  Render                 Render
```

## Deployment URLs Pattern

- **Frontend**: `https://your-project.vercel.app`
- **Backend**: `https://ecoai-backend.onrender.com`
- **AI Service**: `https://ecoai-ai-service.onrender.com`

## Environment Variables Cheat Sheet

### Frontend (Vercel)
```bash
NEXT_PUBLIC_API_URL=https://ecoai-backend.onrender.com
```

### Backend (Render)
```bash
AI_URL=https://ecoai-ai-service.onrender.com
NODE_ENV=production
```

### AI Service (Render)
```bash
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxx
CEREBRAS_API_KEY=csk-xxxxxxxxxxxxxxxxxxxxx
```

## Quick Deploy Steps

### 1. Fork Repository
```bash
# Fork https://github.com/Utpal-Kalita/EcoAI to your account
```

### 2. Deploy AI Service (First!)
- Go to [render.com/deploy](https://render.com/deploy)
- Connect GitHub → Select repo
- Service: `ecoai-ai-service`
- Root Dir: `ai-service`
- Add: `HF_TOKEN` and `CEREBRAS_API_KEY`
- Deploy → Copy URL

### 3. Deploy Backend
- Render → New Web Service
- Service: `ecoai-backend`  
- Root Dir: `backend`
- Add: `AI_URL=<AI_SERVICE_URL_FROM_STEP_2>`
- Deploy → Copy URL

### 4. Deploy Frontend
- Go to [vercel.com/new](https://vercel.com/new)
- Import repo → Root Dir: `frontend`
- Add: `NEXT_PUBLIC_API_URL=<BACKEND_URL_FROM_STEP_3>`
- Deploy → Done! 🎉

## Health Check URLs

After deployment, verify each service:

```bash
# Frontend
curl https://your-project.vercel.app

# Backend  
curl https://ecoai-backend.onrender.com/health

# AI Service
curl https://ecoai-ai-service.onrender.com/health
```

## Common Issues & Fixes

### Issue: Frontend can't reach backend
**Fix**: Update CORS in `backend/server.js`:
```javascript
// Add your Vercel URL to allowed origins
```

### Issue: Backend can't reach AI service  
**Fix**: Check `AI_URL` environment variable in backend

### Issue: Cold start delays (15-60s)
**Fix**: This is normal for free tier - first request wakes up service

### Issue: Build failures
**Fix**: Check logs in Render/Vercel dashboard

## Free Tier Limits

| Service | Limit | Notes |
|---------|-------|-------|
| Vercel | 100GB bandwidth/mo | Plenty for testing |
| Render | 750 hrs/mo per service | Auto-sleeps after 15min idle |
| Railway | $5 credit/mo | Alternative option |

## Cost Estimates

- **Free Tier**: $0/month (Render + Vercel free tiers)
- **Light Usage**: ~$5/month (if exceeding free limits)
- **Production**: $20-30/month (paid plans for uptime)

## Upgrade Paths

**When to upgrade?**
- Need 99.9% uptime
- High traffic (>10k requests/day)
- No cold starts
- Custom domain with SSL

**Recommended upgrades:**
- Vercel Pro: $20/mo
- Render Starter: $7/mo per service

## Monitoring

### Vercel Analytics
- Deployments: [vercel.com/dashboard](https://vercel.com/dashboard)
- Real-time logs available

### Render Dashboard  
- Services: [dashboard.render.com](https://dashboard.render.com)
- Metrics & logs available

## Support Links

- 📘 [Full Deployment Guide](./DEPLOYMENT.md)
- 🚀 [Quick Deploy Guide](./QUICKDEPLOY.md)
- 🐛 [Troubleshooting](./DEPLOYMENT.md#troubleshooting)
- 💬 [Open Issue](https://github.com/Utpal-Kalita/EcoAI/issues)

---

**Pro Tip**: Deploy AI service first, then backend, then frontend to ensure environment variables are set correctly!

Built with ❤️ for a sustainable future 🌍
