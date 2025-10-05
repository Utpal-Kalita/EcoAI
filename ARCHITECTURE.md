# 🎨 EcoAI Deployment Architecture

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER'S BROWSER                          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                     VERCEL (Free Tier)                          │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              Frontend (Next.js 14)                     │    │
│  │  • React 18 with TypeScript                            │    │
│  │  • Tailwind CSS styling                                │    │
│  │  • Carbon footprint calculator                         │    │
│  │  • Interactive visualizations (Recharts)               │    │
│  │  • Responsive design                                   │    │
│  │                                                         │    │
│  │  Environment:                                          │    │
│  │  NEXT_PUBLIC_API_URL=https://backend.onrender.com     │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ REST API (JSON)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    RENDER (Free Tier)                           │
│  ┌────────────────────────────────────────────────────────┐    │
│  │          Backend API (Node.js + Express)               │    │
│  │  • REST API endpoints                                  │    │
│  │  • Carbon footprint calculations                       │    │
│  │  • Request validation                                  │    │
│  │  • Health monitoring                                   │    │
│  │                                                         │    │
│  │  Endpoints:                                            │    │
│  │  • POST /analyze  - Calculate carbon footprint        │    │
│  │  • GET  /health   - Service health check              │    │
│  │                                                         │    │
│  │  Environment:                                          │    │
│  │  AI_URL=https://ai-service.onrender.com               │    │
│  │  NODE_ENV=production                                   │    │
│  └────────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ REST API (JSON)
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    RENDER (Free Tier)                           │
│  ┌────────────────────────────────────────────────────────┐    │
│  │          AI Service (Python + FastAPI)                 │    │
│  │  • Llama 3.1 (via Hugging Face)                        │    │
│  │  • Cerebras SDK for fast inference                     │    │
│  │  • LangChain RAG pipeline                              │    │
│  │  • FAISS vector database                               │    │
│  │  • Sustainability recommendations                       │    │
│  │                                                         │    │
│  │  Endpoints:                                            │    │
│  │  • POST /process  - Generate AI recommendations       │    │
│  │  • GET  /health   - Service health check              │    │
│  │                                                         │    │
│  │  Environment:                                          │    │
│  │  HF_TOKEN=hf_xxxxxxxxxx                                │    │
│  │  CEREBRAS_API_KEY=csk_xxxxxxxxxx                       │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌─────┐    ┌──────────┐    ┌─────────┐    ┌────────────┐
│User │───▶│ Frontend │───▶│ Backend │───▶│ AI Service │
│     │◀───│ (Vercel) │◀───│(Render) │◀───│  (Render)  │
└─────┘    └──────────┘    └─────────┘    └────────────┘
           
           1. User inputs consumption data
           2. Frontend sends to Backend
           3. Backend processes and forwards to AI
           4. AI generates recommendations
           5. Backend returns aggregated response
           6. Frontend displays results
```

## Request Flow Example

```
User Input:
{
  "energy_kwh": 1000,
  "miles_driven": 500,
  "meat_consumption": 5.5
}
    │
    ▼
Frontend (Vercel)
    │ POST /analyze
    ▼
Backend (Render)
    │ Calculates basic footprint
    │ POST /process
    ▼
AI Service (Render)
    │ Generates plan with Llama 3.1
    │ Creates simulation scenarios
    │ Returns recommendations
    ▼
Backend (Render)
    │ Aggregates results
    │ Formats response
    ▼
Frontend (Vercel)
    │ Displays visualizations
    │ Shows recommendations
    ▼
User sees results!
```

## Deployment Topology

```
┌──────────────────── INTERNET ────────────────────┐
│                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │   Vercel    │  │   Render    │  │  Render  │ │
│  │   Global    │  │   Oregon    │  │  Oregon  │ │
│  │     CDN     │  │     DC      │  │    DC    │ │
│  ├─────────────┤  ├─────────────┤  ├──────────┤ │
│  │  Frontend   │  │   Backend   │  │ AI Svc   │ │
│  │  Next.js    │  │  Node.js    │  │  Python  │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
│         │               │                 │      │
└─────────┼───────────────┼─────────────────┼──────┘
          │               │                 │
          └───────────────┴─────────────────┘
                  HTTPS Connections
```

## Service Dependencies

```
Frontend
    ↓ depends on
Backend
    ↓ depends on
AI Service
    ↓ depends on
External APIs:
    • Hugging Face (Llama 3.1)
    • Cerebras Cloud (Inference)
```

## Deployment Sequence

```
Step 1: Deploy AI Service First
    ├─ Install Python dependencies
    ├─ Set HF_TOKEN and CEREBRAS_API_KEY
    ├─ Initialize FAISS vector DB
    └─ ✅ Get AI Service URL

Step 2: Deploy Backend
    ├─ Install Node.js dependencies
    ├─ Set AI_URL from Step 1
    └─ ✅ Get Backend URL

Step 3: Deploy Frontend
    ├─ Install Node.js dependencies
    ├─ Set NEXT_PUBLIC_API_URL from Step 2
    ├─ Build Next.js app
    └─ ✅ Live Application!
```

## Environment Variables Map

```
┌────────────────────────────────────────────┐
│ Frontend (Vercel)                          │
├────────────────────────────────────────────┤
│ NEXT_PUBLIC_API_URL ──────────┐           │
└───────────────────────────────┼───────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────┐
│ Backend (Render)                           │
├────────────────────────────────────────────┤
│ ◀── Points to Backend                     │
│ AI_URL ────────────────────────┐          │
│ NODE_ENV=production            │          │
└────────────────────────────────┼──────────┘
                                 │
                                 ▼
┌────────────────────────────────────────────┐
│ AI Service (Render)                        │
├────────────────────────────────────────────┤
│ ◀── Points to AI Service                  │
│ HF_TOKEN=hf_xxx                            │
│ CEREBRAS_API_KEY=csk_xxx                   │
└────────────────────────────────────────────┘
```

## Cost Breakdown (Free Tier)

```
Service         Cost     Limits                   Notes
─────────────────────────────────────────────────────────
Vercel          $0/mo    100GB bandwidth         ✅ Generous
                         Unlimited builds         ✅ Great for dev
                         
Render (BE)     $0/mo    750 hours/month         ⚠️  Sleeps after 15min
                         500MB RAM                ✅ Enough for Node
                         
Render (AI)     $0/mo    750 hours/month         ⚠️  Sleeps after 15min
                         512MB RAM                ⚠️  Tight for AI
                         
Total           $0/mo    Perfect for demos!      🎉 Free deployment
```

## Performance Characteristics

```
Component         Cold Start    Warm Response    Notes
────────────────────────────────────────────────────────
Frontend          ~100ms        ~50ms            CDN cached
Backend           ~30s          ~200ms           Free tier sleep
AI Service        ~60s          ~1-2s            Model loading
────────────────────────────────────────────────────────
Total (cold)      ~90s          -                First request
Total (warm)      -             ~2s              Subsequent
```

## Scaling Path

```
Traffic Level     Recommended Hosting              Cost
──────────────────────────────────────────────────────────
0-100 req/day     Free tier (current setup)        $0/mo
100-1k req/day    Render Starter + Vercel Pro      $27/mo
1k-10k req/day    Render Standard + Vercel Pro     $47/mo
10k+ req/day      Render Pro + Vercel Pro          $100+/mo
                  + Consider dedicated AI hosting
```

## Monitoring Dashboards

```
┌───────────────────────────────────────────────┐
│ Vercel Dashboard                              │
│ • Deployment history                          │
│ • Analytics & traffic                         │
│ • Function logs                               │
│ • Performance metrics                         │
└───────────────────────────────────────────────┘

┌───────────────────────────────────────────────┐
│ Render Dashboard                              │
│ • Service status                              │
│ • Logs (real-time)                            │
│ • Metrics (CPU, RAM)                          │
│ • Deploy history                              │
└───────────────────────────────────────────────┘
```

## Security Features

```
✅ HTTPS enforced on all services
✅ CORS properly configured
✅ Environment variables encrypted at rest
✅ No credentials in code
✅ API keys in secure environment
✅ Rate limiting (platform level)
```

## Backup & Disaster Recovery

```
Component         Backup Strategy              Recovery Time
────────────────────────────────────────────────────────────────
Code              Git repository               ~5 min (redeploy)
Config            Environment variables        ~2 min (reset vars)
AI Data           FAISS vector DB in code      ~10 min (rebuild)
────────────────────────────────────────────────────────────────
Total                                          ~20 min to restore
```

---

## Quick Links

- 📘 [Full Deployment Guide](./DEPLOYMENT.md)
- 🚀 [Quick Deploy](./QUICKDEPLOY.md)
- 📋 [Quick Reference](./DEPLOY-REFERENCE.md)
- 🏠 [Main README](./README.md)

---

Built with ❤️ for a sustainable future 🌍
