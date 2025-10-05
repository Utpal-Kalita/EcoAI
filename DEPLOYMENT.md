# EcoAI Deployment Guide

This guide will help you deploy EcoAI to free tier hosting services.

## Architecture Overview

- **Frontend (Next.js)**: Deployed on Vercel
- **Backend (Node.js/Express)**: Deployed on Render
- **AI Service (Python/FastAPI)**: Deployed on Render

## Prerequisites

Before deploying, ensure you have:
1. A GitHub account
2. API keys:
   - Hugging Face Token (for Llama 3.1)
   - Cerebras API Key (for accelerated inference)

## Option 1: One-Click Deployment (Recommended)

### Step 1: Deploy to Render (Backend + AI Service)

1. **Fork this repository** to your GitHub account

2. Go to [Render Dashboard](https://dashboard.render.com/)

3. Click **"New"** → **"Blueprint"**

4. Connect your GitHub account and select the forked repository

5. Render will automatically detect the `render.yaml` configuration

6. **Set Environment Variables** for the AI Service:
   - `HF_TOKEN`: Your Hugging Face token
   - `CEREBRAS_API_KEY`: Your Cerebras API key

7. Click **"Apply"** to deploy both services

8. **Note the Backend URL** (e.g., `https://ecoai-backend.onrender.com`)

### Step 2: Deploy to Vercel (Frontend)

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)

2. Click **"Add New"** → **"Project"**

3. Import your forked repository

4. Configure the project:
   - **Framework Preset**: Next.js
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`

5. **Add Environment Variable**:
   - Key: `NEXT_PUBLIC_API_URL`
   - Value: Your Render backend URL (from Step 1)
   - Example: `https://ecoai-backend.onrender.com`

6. Click **"Deploy"**

7. Your frontend will be live at `https://your-project.vercel.app`

## Option 2: Manual Deployment

### Deploy Backend to Render

1. Go to [Render Dashboard](https://dashboard.render.com/)

2. Click **"New"** → **"Web Service"**

3. Connect your repository

4. Configure:
   - **Name**: ecoai-backend
   - **Runtime**: Node
   - **Root Directory**: `backend`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

5. Add environment variable:
   - `AI_URL`: URL of your AI service (deploy AI service first)

6. Click **"Create Web Service"**

### Deploy AI Service to Render

1. Go to [Render Dashboard](https://dashboard.render.com/)

2. Click **"New"** → **"Web Service"**

3. Connect your repository

4. Configure:
   - **Name**: ecoai-ai-service
   - **Runtime**: Python 3
   - **Root Directory**: `ai-service`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app:app --host 0.0.0.0 --port $PORT`

5. Add environment variables:
   - `HF_TOKEN`: Your Hugging Face token
   - `CEREBRAS_API_KEY`: Your Cerebras API key

6. Click **"Create Web Service"**

### Deploy Frontend to Vercel

Follow Step 2 from Option 1 above.

## Option 3: Docker Deployment (Railway)

If you prefer Railway for containerized deployment:

1. Go to [Railway](https://railway.app/)

2. Click **"New Project"** → **"Deploy from GitHub repo"**

3. Select your repository

4. Railway will detect the `docker-compose.yml` and deploy all services

5. Add environment variables in the Railway dashboard

6. Railway will provide URLs for all services

## Post-Deployment Configuration

### Update CORS Settings

If you encounter CORS errors, update the backend `server.js`:

```javascript
app.use(cors({ 
  origin: 'https://your-frontend-url.vercel.app',
  methods: ['GET', 'POST'],
  credentials: true
}));
```

### Update AI Service CORS

Update `ai-service/app.py`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://your-frontend-url.vercel.app",
        "https://ecoai-backend.onrender.com"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Environment Variables Reference

### Frontend (.env.local or Vercel Environment Variables)
```
NEXT_PUBLIC_API_URL=https://ecoai-backend.onrender.com
```

### Backend (Render Environment Variables)
```
NODE_ENV=production
AI_URL=https://ecoai-ai-service.onrender.com
```

### AI Service (Render Environment Variables)
```
HF_TOKEN=your_huggingface_token_here
CEREBRAS_API_KEY=your_cerebras_api_key_here
```

## Getting API Keys

### Hugging Face Token
1. Go to [Hugging Face](https://huggingface.co/)
2. Sign up/Login
3. Go to Settings → Access Tokens
4. Create a new token with read permissions
5. Copy the token

### Cerebras API Key
1. Go to [Cerebras Cloud](https://cloud.cerebras.ai/)
2. Sign up/Login
3. Navigate to API Keys section
4. Generate a new API key
5. Copy the key

## Troubleshooting

### Frontend can't connect to backend
- Verify `NEXT_PUBLIC_API_URL` is set correctly in Vercel
- Check backend service is running on Render
- Ensure CORS is configured properly

### Backend can't connect to AI service
- Verify `AI_URL` environment variable in backend
- Check AI service is deployed and running
- Review AI service logs on Render

### AI Service errors
- Verify `HF_TOKEN` and `CEREBRAS_API_KEY` are set
- Check if FAISS vector database initialized correctly
- Review logs for missing dependencies

### Free Tier Limitations

**Render Free Tier:**
- Services spin down after 15 minutes of inactivity
- First request after spin down may take 30-60 seconds
- 750 hours/month of free runtime

**Vercel Free Tier:**
- Unlimited deployments
- 100GB bandwidth/month
- Serverless function execution limits

### Tips for Free Tier
1. Keep services active by periodic health checks
2. Optimize cold start times
3. Consider upgrading if consistent uptime is needed

## Monitoring

### Check Service Status

**Render:**
- Dashboard shows service status
- View logs in real-time
- Set up health check endpoints

**Vercel:**
- Deployment history available
- Function logs accessible
- Analytics dashboard

## Updating Your Deployment

### Automatic Deployments

Both Render and Vercel support automatic deployments:
1. Push changes to your GitHub repository
2. Services will automatically rebuild and redeploy
3. Monitor deployment status in respective dashboards

### Manual Deployments

**Render:**
- Click "Manual Deploy" → "Deploy latest commit"

**Vercel:**
- Deployments are automatic on push
- Or redeploy from Vercel dashboard

## Custom Domain (Optional)

### Vercel Custom Domain
1. Go to Project Settings → Domains
2. Add your custom domain
3. Follow DNS configuration instructions

### Render Custom Domain
1. Go to Service → Settings → Custom Domains
2. Add your domain
3. Configure DNS records as instructed

## Support & Resources

- **Vercel Documentation**: https://vercel.com/docs
- **Render Documentation**: https://render.com/docs
- **Railway Documentation**: https://docs.railway.app/

## Success Checklist

- [ ] Backend deployed to Render
- [ ] AI Service deployed to Render
- [ ] Frontend deployed to Vercel
- [ ] Environment variables configured
- [ ] CORS settings updated
- [ ] Services can communicate
- [ ] Test the full application flow
- [ ] Monitor logs for errors
- [ ] Set up custom domain (optional)

---

🎉 **Congratulations!** Your EcoAI application is now live!

Access your app at: `https://your-project.vercel.app`

Built with ❤️ for a sustainable future 🌍
