# 🚀 Deployment Visual Guide

## Step-by-Step Visual Deployment Process

### Overview
```
┌──────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT FLOW                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Fork Repo     →   2. Get Keys    →   3. Deploy          │
│                                                              │
│     GitHub              HF + Cerebras       Vercel+Render    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔧 Step 1: Fork Repository

```
┌─────────────────────────────────────────────────────────┐
│  GitHub.com                                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Navigate to:                                           │
│  https://github.com/Utpal-Kalita/EcoAI                  │
│                                                         │
│  Click:  [Fork ▼]  button                               │
│                                                         │
│  Result: Repo copied to your account                    │
│          github.com/YOUR-USERNAME/EcoAI                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🔑 Step 2: Get API Keys

### Hugging Face Token
```
┌─────────────────────────────────────────────────────────┐
│  HuggingFace.co                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Sign up / Login                                     │
│     https://huggingface.co/                             │
│                                                         │
│  2. Go to Settings → Access Tokens                      │
│     https://huggingface.co/settings/tokens              │
│                                                         │
│  3. Click: [New token]                                  │
│     Name: EcoAI                                         │
│     Type: Read                                          │
│                                                         │
│  4. Copy token: hf_xxxxxxxxxxxxxxxxxxxxx                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Cerebras API Key
```
┌─────────────────────────────────────────────────────────┐
│  Cerebras Cloud                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Sign up / Login                                     │
│     https://cloud.cerebras.ai/                          │
│                                                         │
│  2. Navigate to: API Keys                               │
│                                                         │
│  3. Click: [Generate New Key]                           │
│     Name: EcoAI                                         │
│                                                         │
│  4. Copy key: csk_xxxxxxxxxxxxxxxxxxxxx                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Step 3: Deploy Services

### 3.1 Deploy AI Service (FIRST!)

```
┌──────────────────────────────────────────────────────────────┐
│  Render.com Dashboard                                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ① Click: [New +] → [Web Service]                           │
│                                                              │
│  ② Connect GitHub account                                   │
│                                                              │
│  ③ Select repository: YOUR-USERNAME/EcoAI                    │
│                                                              │
│  ④ Configure:                                               │
│     ┌──────────────────────────────────┐                    │
│     │ Name:         ecoai-ai-service   │                    │
│     │ Runtime:      Python 3           │                    │
│     │ Region:       Oregon (US West)   │                    │
│     │ Branch:       main               │                    │
│     │ Root Dir:     ai-service         │                    │
│     │ Build:        pip install -r ... │                    │
│     │ Start:        uvicorn app:app... │                    │
│     │ Plan:         Free               │                    │
│     └──────────────────────────────────┘                    │
│                                                              │
│  ⑤ Environment Variables:                                   │
│     ┌────────────────────────────────────────┐              │
│     │ Key                 │ Value             │              │
│     ├────────────────────────────────────────┤              │
│     │ HF_TOKEN            │ hf_xxxxx...       │              │
│     │ CEREBRAS_API_KEY    │ csk_xxxxx...      │              │
│     │ PYTHON_VERSION      │ 3.9.18            │              │
│     └────────────────────────────────────────┘              │
│                                                              │
│  ⑥ Click: [Create Web Service]                              │
│                                                              │
│  ⑦ Wait: ~3-5 minutes for deployment                        │
│                                                              │
│  ⑧ Copy URL:                                                │
│     https://ecoai-ai-service-xxxx.onrender.com              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Deploy Backend (SECOND)

```
┌──────────────────────────────────────────────────────────────┐
│  Render.com Dashboard                                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ① Click: [New +] → [Web Service]                           │
│                                                              │
│  ② Select same repository: YOUR-USERNAME/EcoAI              │
│                                                              │
│  ③ Configure:                                               │
│     ┌──────────────────────────────────┐                    │
│     │ Name:         ecoai-backend      │                    │
│     │ Runtime:      Node               │                    │
│     │ Region:       Oregon (US West)   │                    │
│     │ Branch:       main               │                    │
│     │ Root Dir:     backend            │                    │
│     │ Build:        npm install        │                    │
│     │ Start:        npm start          │                    │
│     │ Plan:         Free               │                    │
│     └──────────────────────────────────┘                    │
│                                                              │
│  ④ Environment Variables:                                   │
│     ┌────────────────────────────────────────────────────┐  │
│     │ Key            │ Value                             │  │
│     ├────────────────────────────────────────────────────┤  │
│     │ AI_URL         │ https://ecoai-ai-service-xxxx..   │  │
│     │                │ (from Step 3.1)                   │  │
│     │ NODE_ENV       │ production                        │  │
│     └────────────────────────────────────────────────────┘  │
│                                                              │
│  ⑤ Click: [Create Web Service]                              │
│                                                              │
│  ⑥ Wait: ~2-3 minutes for deployment                        │
│                                                              │
│  ⑦ Copy URL:                                                │
│     https://ecoai-backend-xxxx.onrender.com                 │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3.3 Deploy Frontend (FINAL)

```
┌──────────────────────────────────────────────────────────────┐
│  Vercel.com Dashboard                                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ① Click: [Add New...] → [Project]                          │
│                                                              │
│  ② Import Git Repository                                    │
│     - Connect GitHub account                                │
│     - Select: YOUR-USERNAME/EcoAI                            │
│                                                              │
│  ③ Configure Project:                                       │
│     ┌──────────────────────────────────┐                    │
│     │ Framework:    Next.js (detected) │                    │
│     │ Root Dir:     frontend           │                    │
│     │ Build:        npm run build      │                    │
│     │ Output Dir:   .next              │                    │
│     └──────────────────────────────────┘                    │
│                                                              │
│  ④ Environment Variables:                                   │
│     ┌──────────────────────────────────────────────────┐    │
│     │ Key                      │ Value                 │    │
│     ├──────────────────────────────────────────────────┤    │
│     │ NEXT_PUBLIC_API_URL      │ https://ecoai-ba...   │    │
│     │                          │ (from Step 3.2)       │    │
│     └──────────────────────────────────────────────────┘    │
│                                                              │
│  ⑤ Click: [Deploy]                                           │
│                                                              │
│  ⑥ Wait: ~2-4 minutes for build & deployment                │
│                                                              │
│  ⑦ Your app is live! 🎉                                      │
│     https://your-project.vercel.app                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## ✅ Verification Steps

### Check AI Service Health
```bash
┌────────────────────────────────────────────┐
│ $ curl https://your-ai-service.onrender.com/health
│                                            │
│ Response:                                  │
│ {                                          │
│   "status": "ok",                          │
│   "message": "EcoAI AI Service is running" │
│ }                                          │
└────────────────────────────────────────────┘
```

### Check Backend Health
```bash
┌────────────────────────────────────────────┐
│ $ curl https://your-backend.onrender.com/health
│                                            │
│ Response:                                  │
│ {                                          │
│   "status": "ok",                          │
│   "ai_service": "connected",               │
│   "uptime": 123.45                         │
│ }                                          │
└────────────────────────────────────────────┘
```

### Test Frontend
```
┌────────────────────────────────────────────────────────┐
│  Browser: https://your-project.vercel.app              │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ✅ Page loads                                         │
│  ✅ Form is visible                                    │
│  ✅ No console errors                                  │
│  ✅ Can submit form                                    │
│  ✅ Results display correctly                          │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 🎨 Visual Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        INTERNET                         │
│                      (HTTPS Only)                       │
└────────────┬────────────────────────┬───────────────────┘
             │                        │
             ▼                        ▼
┌────────────────────┐   ┌──────────────────────────────┐
│     VERCEL         │   │         RENDER               │
│  Global CDN        │   │      Oregon (US West)        │
├────────────────────┤   ├──────────────────────────────┤
│                    │   │                              │
│   Frontend         │───▶│   Backend                   │
│   (Next.js)        │   │   (Node.js)                 │
│                    │   │                              │
│   Port: 3000       │   │   Port: 3001                │
│   Free Tier        │   │   Free Tier (750hrs/mo)     │
│                    │   │                │             │
└────────────────────┘   └────────────────┼─────────────┘
                                          │
                                          ▼
                         ┌────────────────────────────┐
                         │       RENDER              │
                         │    Oregon (US West)       │
                         ├────────────────────────────┤
                         │                           │
                         │   AI Service              │
                         │   (Python/FastAPI)        │
                         │                           │
                         │   Port: 8000              │
                         │   Free Tier (750hrs/mo)   │
                         │                           │
                         └────────────────────────────┘
```

---

## 📊 Deployment Timeline

```
Time        Step                    Status
────────────────────────────────────────────
0:00        Fork repository         ✅
0:01        Get API keys            ✅
            ├─ HuggingFace
            └─ Cerebras
            
0:05        Deploy AI Service       🔄
            ├─ Create service
            ├─ Set env vars
            └─ Build & deploy
            
0:10        Deploy Backend          🔄
            ├─ Create service
            ├─ Set env vars
            └─ Build & deploy
            
0:13        Deploy Frontend         🔄
            ├─ Import project
            ├─ Set env vars
            └─ Build & deploy
            
0:15        Verify deployment       ✅
            ├─ Test AI health
            ├─ Test backend health
            └─ Test frontend
            
0:17        LIVE! 🎉                ✅
```

---

## 🔄 Automatic Deployments

```
┌────────────────────────────────────────────────────────┐
│                 GitHub Repository                      │
│            github.com/YOUR-USERNAME/EcoAI              │
└───────────────────────┬────────────────────────────────┘
                        │
                        │ On git push
                        │
          ┌─────────────┼─────────────┐
          │             │             │
          ▼             ▼             ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │ Vercel  │   │ Render  │   │ Render  │
    │Frontend │   │ Backend │   │   AI    │
    └─────────┘   └─────────┘   └─────────┘
          │             │             │
          └─────────────┼─────────────┘
                        │
                        ▼
              Automatic Redeploy!
```

---

## 💡 Quick Tips

### Keep Services Warm (Avoid Cold Starts)
```
┌────────────────────────────────────────────┐
│  Use cron-job.org to ping every 10 min    │
│                                            │
│  GET /health every 10 minutes:            │
│  • https://your-backend.onrender.com      │
│  • https://your-ai-service.onrender.com   │
│                                            │
│  Result: No cold starts! ⚡                 │
└────────────────────────────────────────────┘
```

### Monitor Logs
```
Vercel:  Dashboard → Project → Deployments → Function Logs
Render:  Dashboard → Service → Logs (Real-time)
```

### Update Environment Variables
```
Both Vercel & Render: Changes require redeployment
  1. Update variable in dashboard
  2. Trigger manual redeploy
  3. Wait for build to complete
```

---

## 🎉 Success!

```
┌────────────────────────────────────────────────────────┐
│                                                        │
│         🎊 DEPLOYMENT COMPLETE! 🎊                     │
│                                                        │
│  Your EcoAI app is now live at:                        │
│  https://your-project.vercel.app                       │
│                                                        │
│  Cost:  $0/month                                       │
│  Time:  ~15 minutes                                    │
│                                                        │
│  Next Steps:                                           │
│  ✅ Test the application                               │
│  ✅ Share with friends                                 │
│  ✅ Monitor performance                                │
│  ✅ Gather feedback                                    │
│                                                        │
│  Built with ❤️ for a sustainable future 🌍             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 📚 Related Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Complete deployment guide
- [QUICKDEPLOY.md](./QUICKDEPLOY.md) - Quick start guide
- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Common issues
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [CHECKLIST.md](./CHECKLIST.md) - Deployment checklist

---

**Need Help?** Open an issue on GitHub!
