# ✅ Deployment Checklist

Use this checklist to ensure a smooth deployment of EcoAI.

## Pre-Deployment Checklist

### 1. Prerequisites
- [ ] GitHub account created
- [ ] Vercel account created ([vercel.com](https://vercel.com))
- [ ] Render account created ([render.com](https://render.com))
- [ ] Repository forked to your GitHub account

### 2. API Keys Ready
- [ ] Hugging Face account created
- [ ] Hugging Face API token obtained
- [ ] Cerebras account created
- [ ] Cerebras API key obtained

### 3. Documentation Review
- [ ] Read [DEPLOYMENT.md](./DEPLOYMENT.md)
- [ ] Read [QUICKDEPLOY.md](./QUICKDEPLOY.md)
- [ ] Understand [ARCHITECTURE.md](./ARCHITECTURE.md)

---

## Deployment Steps

### Phase 1: Deploy AI Service (First!)

- [ ] Log in to Render
- [ ] Click "New" → "Web Service"
- [ ] Connect GitHub account
- [ ] Select forked repository
- [ ] Configure service:
  - [ ] Name: `ecoai-ai-service`
  - [ ] Runtime: Python 3
  - [ ] Root Directory: `ai-service`
  - [ ] Build Command: `pip install -r requirements.txt`
  - [ ] Start Command: `uvicorn app:app --host 0.0.0.0 --port $PORT`
- [ ] Add environment variables:
  - [ ] `HF_TOKEN`: [Your Hugging Face token]
  - [ ] `CEREBRAS_API_KEY`: [Your Cerebras API key]
- [ ] Click "Create Web Service"
- [ ] Wait for deployment to complete (3-5 minutes)
- [ ] Test health endpoint: `/health`
- [ ] **Copy AI Service URL**: `____________________`

### Phase 2: Deploy Backend

- [ ] In Render, click "New" → "Web Service"
- [ ] Select same repository
- [ ] Configure service:
  - [ ] Name: `ecoai-backend`
  - [ ] Runtime: Node
  - [ ] Root Directory: `backend`
  - [ ] Build Command: `npm install`
  - [ ] Start Command: `npm start`
- [ ] Add environment variables:
  - [ ] `AI_URL`: [AI Service URL from Phase 1]
  - [ ] `NODE_ENV`: `production`
- [ ] Click "Create Web Service"
- [ ] Wait for deployment to complete (2-3 minutes)
- [ ] Test health endpoint: `/health`
- [ ] Verify AI connection in health response
- [ ] **Copy Backend URL**: `____________________`

### Phase 3: Deploy Frontend

- [ ] Log in to Vercel
- [ ] Click "Add New" → "Project"
- [ ] Import your forked repository
- [ ] Configure project:
  - [ ] Framework Preset: Next.js
  - [ ] Root Directory: `frontend`
  - [ ] Build Command: (leave default)
  - [ ] Output Directory: (leave default)
- [ ] Add environment variable:
  - [ ] Key: `NEXT_PUBLIC_API_URL`
  - [ ] Value: [Backend URL from Phase 2]
- [ ] Click "Deploy"
- [ ] Wait for deployment to complete (2-4 minutes)
- [ ] **Copy Frontend URL**: `____________________`

---

## Post-Deployment Verification

### Test Each Service

#### AI Service
```bash
curl https://[your-ai-service].onrender.com/health
```
- [ ] Returns `{"status":"ok"}`
- [ ] Response time < 5 seconds

#### Backend
```bash
curl https://[your-backend].onrender.com/health
```
- [ ] Returns `{"status":"ok"}`
- [ ] Shows `"ai_service":"connected"`
- [ ] Response time < 3 seconds

#### Frontend
```bash
curl -I https://[your-project].vercel.app
```
- [ ] Returns `200 OK`
- [ ] Page loads in browser
- [ ] No console errors

### Test Full Flow

- [ ] Open frontend in browser
- [ ] Fill in the carbon footprint form:
  - [ ] Energy consumption field
  - [ ] Travel distance field
  - [ ] Meat consumption field
- [ ] Click "Calculate My Carbon Footprint"
- [ ] Results display correctly:
  - [ ] Total footprint shown
  - [ ] Breakdown chart visible
  - [ ] Recommendations displayed
  - [ ] Simulation shown
- [ ] Try different values
- [ ] Verify responsiveness on mobile

---

## Configuration Updates

### Update CORS (if needed)

#### Backend CORS
- [ ] Open `backend/server.js`
- [ ] Add your Vercel URL to allowed origins
- [ ] Commit and push changes
- [ ] Render auto-redeploys

#### AI Service CORS
- [ ] Open `ai-service/app.py`
- [ ] Verify regex includes your domains
- [ ] Commit and push if needed
- [ ] Render auto-redeploys

### Environment Variables Review

#### Frontend
- [ ] `NEXT_PUBLIC_API_URL` points to backend
- [ ] No trailing slashes in URL

#### Backend
- [ ] `AI_URL` points to AI service
- [ ] No trailing slashes in URL
- [ ] `NODE_ENV=production`

#### AI Service
- [ ] `HF_TOKEN` is valid
- [ ] `CEREBRAS_API_KEY` is valid
- [ ] Both keys work (no quota exceeded)

---

## Performance Check

### Cold Start Test
- [ ] Wait 20 minutes for services to sleep
- [ ] Test frontend → expect 30-60s delay (normal)
- [ ] Subsequent requests fast (1-2s)

### Warm Performance
- [ ] Frontend loads < 2s
- [ ] API requests complete < 3s
- [ ] AI responses generate < 5s

---

## Monitoring Setup

### Vercel Monitoring
- [ ] Enable Vercel Analytics
- [ ] Set up deployment notifications
- [ ] Review function logs

### Render Monitoring
- [ ] Check service metrics
- [ ] Enable email notifications
- [ ] Review service logs
- [ ] Set up health check alerts (optional)

---

## Documentation Updates

### Update Repository
- [ ] Update README with live URLs
- [ ] Add deployment status badges
- [ ] Document any custom configurations
- [ ] Update screenshots if needed

### Internal Documentation
- [ ] Document live URLs
- [ ] Note any configuration changes
- [ ] Record API key locations
- [ ] Save troubleshooting notes

---

## Security Checklist

- [ ] API keys not in code
- [ ] Environment variables encrypted
- [ ] HTTPS enforced on all services
- [ ] CORS properly configured
- [ ] No sensitive data in logs
- [ ] Repository secrets not exposed

---

## Optional Enhancements

### Custom Domain
- [ ] Purchase domain
- [ ] Configure DNS in Vercel
- [ ] Configure DNS in Render
- [ ] Verify SSL certificates

### Keep-Alive Service
- [ ] Set up cron job to ping services
- [ ] Use [cron-job.org](https://cron-job.org) or similar
- [ ] Ping every 10 minutes
- [ ] Prevent free tier sleep

### Analytics
- [ ] Enable Vercel Analytics
- [ ] Set up Google Analytics (optional)
- [ ] Monitor usage patterns
- [ ] Track performance metrics

### Backup Strategy
- [ ] Document environment variables
- [ ] Save configuration files
- [ ] Keep API keys secure
- [ ] Document deployment process

---

## Success Criteria

### Deployment Complete ✅

- [x] All three services deployed
- [x] All health checks passing
- [x] Frontend loads successfully
- [x] Full user flow works
- [x] No console errors
- [x] Mobile responsive
- [x] CORS configured
- [x] Environment variables set
- [x] Services communicate properly
- [x] Documentation updated

---

## Next Steps

After successful deployment:

1. **Share with users**
   - Post on social media
   - Share with team
   - Gather feedback

2. **Monitor performance**
   - Check logs daily
   - Review metrics
   - Track errors

3. **Plan upgrades**
   - Monitor free tier usage
   - Plan for scaling
   - Consider paid tiers

4. **Continuous improvement**
   - Fix bugs
   - Add features
   - Optimize performance

---

## Troubleshooting

If anything goes wrong, check:

1. **[Troubleshooting Guide](./TROUBLESHOOTING.md)**
2. Service logs in Render/Vercel
3. Browser console for errors
4. Health check endpoints
5. Environment variables

---

## Getting Help

**Documentation:**
- [Full Deployment Guide](./DEPLOYMENT.md)
- [Quick Deploy](./QUICKDEPLOY.md)
- [Architecture](./ARCHITECTURE.md)
- [Troubleshooting](./TROUBLESHOOTING.md)

**Support:**
- [Open an Issue](https://github.com/Utpal-Kalita/EcoAI/issues)
- Check service status pages
- Community forums

---

## Deployment Notes

**Date Deployed**: `_______________`

**URLs:**
- Frontend: `_______________`
- Backend: `_______________`
- AI Service: `_______________`

**Issues Encountered**: `_______________`

**Notes**: `_______________`

---

🎉 **Congratulations on deploying EcoAI!**

Built with ❤️ for a sustainable future 🌍

[Back to Main README](./README.md)
