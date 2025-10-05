# 🚀 Quick Deploy to Free Hosting

Deploy EcoAI to free tier hosting services in minutes!

## Deploy with One Click

### Option 1: Render (Backend + AI) + Vercel (Frontend)

**Step 1: Deploy Backend & AI Service to Render**

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

1. Click the button above
2. Connect your GitHub account
3. Select this repository
4. Add environment variables:
   - `HF_TOKEN`: Your Hugging Face token
   - `CEREBRAS_API_KEY`: Your Cerebras API key
5. Click "Apply"

**Step 2: Deploy Frontend to Vercel**

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/Utpal-Kalita/EcoAI&project-name=ecoai&repository-name=ecoai&root-directory=frontend&env=NEXT_PUBLIC_API_URL&envDescription=Backend%20API%20URL%20from%20Render&envLink=https://github.com/Utpal-Kalita/EcoAI/blob/main/DEPLOYMENT.md)

1. Click the button above
2. Connect your GitHub account
3. Set `NEXT_PUBLIC_API_URL` to your Render backend URL
4. Click "Deploy"

### Option 2: Railway (Full Stack)

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template?template=https://github.com/Utpal-Kalita/EcoAI)

1. Click the button above
2. Connect your GitHub account
3. Add environment variables:
   - `HF_TOKEN`: Your Hugging Face token
   - `CEREBRAS_API_KEY`: Your Cerebras API key
   - `NEXT_PUBLIC_API_URL`: Will be auto-set by Railway
4. Click "Deploy"

## Free Tier Specifications

### Vercel (Frontend)
- ✅ Unlimited deployments
- ✅ 100GB bandwidth/month
- ✅ Automatic HTTPS
- ✅ Global CDN

### Render (Backend + AI)
- ✅ 750 hours/month free runtime
- ✅ Automatic HTTPS
- ✅ Spins down after 15 min inactivity
- ⚠️ Cold start: 30-60s after inactivity

### Railway (Alternative)
- ✅ $5 free credit/month
- ✅ Auto-scaling
- ✅ Automatic HTTPS
- ✅ Built-in databases

## Getting API Keys

### Hugging Face Token (Required)
1. Visit [huggingface.co](https://huggingface.co/)
2. Sign up or login
3. Go to Settings → Access Tokens
4. Create new token with read access
5. Copy the token

### Cerebras API Key (Required)
1. Visit [cloud.cerebras.ai](https://cloud.cerebras.ai/)
2. Sign up or login
3. Navigate to API Keys
4. Generate new API key
5. Copy the key

## What Gets Deployed?

### Frontend (Vercel)
- Next.js 14 application
- React 18 with TypeScript
- Tailwind CSS for styling
- Interactive carbon calculator
- Beautiful visualizations

### Backend (Render)
- Node.js/Express API
- REST endpoints for analysis
- Connects to AI service
- Health check endpoint

### AI Service (Render)
- Python FastAPI service
- Llama 3.1 integration
- Cerebras acceleration
- RAG with LangChain
- FAISS vector database

## Post-Deployment

After deployment:
1. ✅ Frontend is live on Vercel
2. ✅ Backend is live on Render
3. ✅ AI Service is live on Render
4. ✅ All services are connected

## Troubleshooting

**Services not connecting?**
- Verify environment variables are set
- Check CORS configuration
- Review service logs

**Slow response times?**
- Free tier services spin down when idle
- First request may take 30-60 seconds
- Consider upgrading for production use

## Full Deployment Guide

For detailed step-by-step instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md)

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Vercel    │────▶│   Render    │────▶│   Render    │
│  Frontend   │     │   Backend   │     │ AI Service  │
│  (Next.js)  │     │  (Node.js)  │     │  (Python)   │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Cost Estimate

- **Free Tier**: $0/month (with limitations)
- **Light Use**: $5-10/month (upgrade for better performance)
- **Production**: $20-30/month (recommended for real users)

---

🌍 **Start reducing your carbon footprint today!**

For support, open an issue or check the [full documentation](./DEPLOYMENT.md).
