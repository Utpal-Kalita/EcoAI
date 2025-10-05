# 🔧 Troubleshooting Guide

Common issues and solutions for deploying EcoAI.

## Table of Contents

1. [Deployment Issues](#deployment-issues)
2. [Connection Issues](#connection-issues)
3. [Performance Issues](#performance-issues)
4. [API Issues](#api-issues)
5. [Build Issues](#build-issues)
6. [Environment Variable Issues](#environment-variable-issues)

---

## Deployment Issues

### Issue: Render build fails for AI service

**Symptoms:**
```
ERROR: Could not find a version that satisfies the requirement
```

**Solution:**
```bash
# Ensure requirements.txt uses compatible versions
# Check Python version in Render (should be 3.9+)
```

**Fix:**
1. Go to Render Dashboard → AI Service → Settings
2. Set Environment Variable: `PYTHON_VERSION=3.9.18`
3. Trigger manual deploy

---

### Issue: Vercel build fails

**Symptoms:**
```
Error: Cannot find module 'next'
```

**Solution:**
1. Check `frontend/package.json` exists
2. Verify Root Directory is set to `frontend` in Vercel
3. Clear Vercel cache and redeploy

**Steps:**
```bash
# In Vercel Dashboard
Project Settings → General → Root Directory: frontend
Deployments → Latest → Redeploy
```

---

### Issue: Backend won't start on Render

**Symptoms:**
```
Error: Cannot find module 'express'
```

**Solution:**
1. Verify `backend/package.json` exists
2. Check build command: `npm install`
3. Check start command: `npm start`

---

## Connection Issues

### Issue: Frontend can't connect to backend

**Symptoms:**
- Network errors in browser console
- `Failed to fetch` errors
- CORS errors

**Solution 1: Check Environment Variable**
```bash
# In Vercel Dashboard
Settings → Environment Variables
NEXT_PUBLIC_API_URL = https://ecoai-backend.onrender.com
```

**Solution 2: Verify CORS**
```javascript
// backend/server.js should include your Vercel URL
// Add your actual Vercel URL to allowed origins
```

**Solution 3: Check Backend Status**
```bash
curl https://ecoai-backend.onrender.com/health
# Should return: {"status":"ok",...}
```

---

### Issue: Backend can't connect to AI service

**Symptoms:**
```json
{
  "status": "degraded",
  "ai_service": "error"
}
```

**Solution 1: Check AI_URL**
```bash
# In Render Dashboard → Backend → Environment
AI_URL = https://ecoai-ai-service.onrender.com
```

**Solution 2: Verify AI Service is Running**
```bash
curl https://ecoai-ai-service.onrender.com/health
# Should return: {"status":"ok",...}
```

**Solution 3: Check Logs**
```bash
# Render Dashboard → Backend → Logs
# Look for connection errors
```

---

### Issue: CORS errors in browser

**Symptoms:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**Solution 1: Update Backend CORS**
```javascript
// backend/server.js
// Add your Vercel URL to allowed origins list
const allowedOrigins = [
  'https://your-app.vercel.app',  // Add your URL
  ...
];
```

**Solution 2: Update AI Service CORS**
```python
# ai-service/app.py
# Verify regex pattern includes your domains
allow_origin_regex=r"https://.*\.(vercel\.app|onrender\.com)"
```

**Solution 3: Redeploy After Changes**
```bash
git commit -am "Update CORS settings"
git push
# Services will auto-redeploy
```

---

## Performance Issues

### Issue: Very slow first request (30-60 seconds)

**Cause:** Free tier services spin down after 15 minutes of inactivity

**Solution 1: Expected Behavior**
- This is normal for free tier
- Subsequent requests are fast (~1-2s)

**Solution 2: Keep Services Warm**
```bash
# Use a cron job to ping services every 10 minutes
# Example with cron-job.org:
GET https://ecoai-backend.onrender.com/health
GET https://ecoai-ai-service.onrender.com/health
```

**Solution 3: Upgrade to Paid Plan**
```
Render Starter: $7/month per service
- No cold starts
- Always running
```

---

### Issue: Requests timing out

**Symptoms:**
```
Error: Request timeout
```

**Solution 1: Check Service Status**
```bash
# All services should return 200 OK
curl -I https://ecoai-backend.onrender.com/health
curl -I https://ecoai-ai-service.onrender.com/health
```

**Solution 2: Increase Timeout**
```javascript
// In frontend API calls
axios.post('/analyze', data, {
  timeout: 60000  // 60 seconds
})
```

**Solution 3: Check Render Logs**
```bash
# Render Dashboard → Service → Logs
# Look for errors or crashes
```

---

## API Issues

### Issue: API returns 500 Internal Server Error

**Symptoms:**
```json
{
  "error": "Internal server error"
}
```

**Solution 1: Check Backend Logs**
```bash
# Render Dashboard → Backend → Logs
# Look for stack traces
```

**Solution 2: Verify AI Service**
```bash
curl -X POST https://ecoai-ai-service.onrender.com/process \
  -H "Content-Type: application/json" \
  -d '{"energy_kwh":100,"miles_driven":50,"meat_consumption":5}'
```

**Solution 3: Check Environment Variables**
```bash
# Render Dashboard → AI Service → Environment
# Verify HF_TOKEN and CEREBRAS_API_KEY are set
```

---

### Issue: Missing API keys

**Symptoms:**
```
Error: Authentication failed
```

**Solution:**
```bash
# Render Dashboard → AI Service → Environment Variables
# Add:
HF_TOKEN=hf_xxxxxxxxxxxxx
CEREBRAS_API_KEY=csk_xxxxxxxxxxxxx

# Then redeploy:
Manual Deploy → Deploy latest commit
```

---

### Issue: Invalid API response format

**Symptoms:**
```
TypeError: Cannot read property 'totalFootprint' of undefined
```

**Solution 1: Check API Response**
```bash
curl -X POST https://ecoai-backend.onrender.com/analyze \
  -H "Content-Type: application/json" \
  -d '{"energy_kwh":1000,"miles_driven":500,"meat_consumption":5.5}'
```

**Solution 2: Verify Response Format**
```json
// Expected format:
{
  "totalFootprint": 12.34,
  "breakdown": {
    "energy": 40.5,
    "travel": 35.2,
    "food": 24.3
  },
  "plan": ["...", "..."],
  "simulation": {...}
}
```

---

## Build Issues

### Issue: Frontend build fails on Vercel

**Symptoms:**
```
Type error: Cannot find name 'process'
```

**Solution:**
```bash
# In Vercel Dashboard
Settings → Environment Variables
NEXT_PUBLIC_API_URL = https://your-backend.onrender.com

# Redeploy
Deployments → Redeploy
```

---

### Issue: Backend build fails on Render

**Symptoms:**
```
npm ERR! missing script: start
```

**Solution:**
```json
// backend/package.json should have:
{
  "scripts": {
    "start": "node server.js"
  }
}
```

---

### Issue: AI service build fails

**Symptoms:**
```
ERROR: No matching distribution found for package
```

**Solution 1: Check Python Version**
```bash
# Render Dashboard → AI Service → Environment
PYTHON_VERSION=3.9.18
```

**Solution 2: Update requirements.txt**
```txt
# Use compatible versions
fastapi>=0.68.0
uvicorn>=0.15.0
transformers>=4.18.0
...
```

---

## Environment Variable Issues

### Issue: Environment variables not working

**Symptoms:**
- `undefined` in logs
- Connection failures

**Solution 1: Verify Variables are Set**
```bash
# Render Dashboard → Service → Environment
# Vercel Dashboard → Project → Settings → Environment Variables
```

**Solution 2: Check Variable Names**
```bash
# Frontend (must start with NEXT_PUBLIC_)
NEXT_PUBLIC_API_URL ✅
API_URL ❌

# Backend
AI_URL ✅
ai_url ❌

# AI Service
HF_TOKEN ✅
HUGGING_FACE_TOKEN ❌
```

**Solution 3: Redeploy After Changes**
```bash
# Changes to environment variables require redeployment
# Render: Manual Deploy → Deploy latest commit
# Vercel: Automatic on git push
```

---

### Issue: Environment variable not visible

**Cause:** Frontend environment variables must be set at build time

**Solution:**
```bash
# For Vercel:
# 1. Add variable in Settings → Environment Variables
# 2. Check "Production", "Preview", and "Development"
# 3. Redeploy

# Variable must start with NEXT_PUBLIC_
NEXT_PUBLIC_API_URL ✅
```

---

## Health Check Issues

### Issue: Health check returns "degraded"

**Symptoms:**
```json
{
  "status": "degraded",
  "ai_service": "error"
}
```

**Solution:**
1. This means backend is running but can't reach AI service
2. Check AI_URL environment variable
3. Verify AI service is running
4. Check AI service logs

---

### Issue: Health check returns 503

**Symptoms:**
```
Service Unavailable
```

**Solution:**
1. Service is starting up (wait 30-60s)
2. Service crashed (check logs)
3. Resource limits exceeded (upgrade plan)

---

## Getting Help

### Steps to Debug:

1. **Check Service Status**
   ```bash
   curl https://your-service.onrender.com/health
   ```

2. **Check Logs**
   - Render: Dashboard → Service → Logs
   - Vercel: Dashboard → Project → Deployments → View Function Logs

3. **Test Endpoints**
   ```bash
   # Backend
   curl https://backend.onrender.com/health
   
   # AI Service
   curl https://ai-service.onrender.com/health
   ```

4. **Verify Environment Variables**
   - Check all required variables are set
   - Verify values are correct (no typos)
   - Ensure no trailing spaces

5. **Check CORS**
   - Open browser console
   - Look for CORS errors
   - Verify frontend URL in backend CORS config

---

## Still Having Issues?

1. **Review Documentation:**
   - [Deployment Guide](./DEPLOYMENT.md)
   - [Quick Deploy](./QUICKDEPLOY.md)
   - [Architecture](./ARCHITECTURE.md)

2. **Check Service Status Pages:**
   - [Vercel Status](https://www.vercel-status.com/)
   - [Render Status](https://status.render.com/)

3. **Open an Issue:**
   - [GitHub Issues](https://github.com/Utpal-Kalita/EcoAI/issues)
   - Include logs and error messages
   - Describe what you've tried

4. **Community Support:**
   - Vercel Discord: [discord.gg/vercel](https://discord.gg/vercel)
   - Render Community: [community.render.com](https://community.render.com)

---

## Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Slow first request | Normal for free tier, wait 30-60s |
| CORS error | Add frontend URL to backend CORS config |
| 500 error | Check logs, verify API keys |
| Build fails | Check build command and dependencies |
| Can't connect | Verify environment variables |
| Health check fails | Check service logs and status |

---

Built with ❤️ for a sustainable future 🌍

[Back to Main README](./README.md)
