# EcoAI Deployment Guide

This guide provides step-by-step instructions to deploy the EcoAI application using Docker Compose.

## Prerequisites

- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git
- API Keys:
  - Hugging Face Token (for Llama 3.1)
  - Cerebras API Key

## Quick Start (Recommended)

### 1. Clone the Repository
```bash
git clone https://github.com/Utpal-Kalita/EcoAI.git
cd EcoAI
```

### 2. Configure Environment Variables
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and add your API keys
# Required:
# - HF_TOKEN=your_huggingface_token
# - CEREBRAS_API_KEY=your_cerebras_api_key
```

### 3. Deploy with Docker Compose
```bash
# Build and start all services
docker-compose up --build -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **AI Service**: http://localhost:8000

## Detailed Deployment Steps

### Environment Configuration

#### Root `.env` File
Create a `.env` file in the root directory with the following variables:

```env
# API Keys (REQUIRED)
HF_TOKEN=your_huggingface_token_here
CEREBRAS_API_KEY=your_cerebras_api_key_here

# Service Ports
FRONTEND_PORT=3000
BACKEND_PORT=3001
AI_SERVICE_PORT=8000

# Service URLs
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:3001
AI_SERVICE_URL=http://localhost:8000
```

#### Frontend `.env` File
Create `frontend/.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

#### Backend `.env` File
Create `backend/.env`:

```env
AI_URL=http://ai:8000
PORT=3001
```

### Building Individual Services

If you prefer to build services individually:

#### Frontend
```bash
cd frontend
docker build -t ecoai-frontend .
docker run -p 3000:3000 --env-file .env.local ecoai-frontend
```

#### Backend
```bash
cd backend
docker build -t ecoai-backend .
docker run -p 3001:3001 --env-file .env ecoai-backend
```

#### AI Service
```bash
cd ai-service
docker build -t ecoai-ai-service .
docker run -p 8000:8000 --env-file ../.env ecoai-ai-service
```

## Health Checks

After deployment, verify all services are running:

```bash
# Backend health check
curl http://localhost:3001/health

# AI service health check
curl http://localhost:8000/health

# Frontend (check if page loads)
curl http://localhost:3000
```

Expected responses:
- Backend: `{"status":"ok","message":"EcoAI backend is running"}`
- AI Service: `{"status":"healthy","model":"llama3.1-8b"}`

## Troubleshooting

### Service Connection Issues

If services can't communicate:

1. **Check Docker network**:
   ```bash
   docker network ls
   docker network inspect ecoai_ecoai-net
   ```

2. **Verify service names**:
   - Services should use internal Docker names: `backend`, `ai`, `frontend`
   - Not `localhost` when communicating between services

3. **Check logs**:
   ```bash
   docker-compose logs backend
   docker-compose logs ai
   docker-compose logs frontend
   ```

### AI Service Fails to Start

Common issues:
1. **Missing API keys**: Ensure `HF_TOKEN` and `CEREBRAS_API_KEY` are set in `.env`
2. **FAISS index not built**: The AI service builds the FAISS index during Docker build
3. **Memory issues**: AI service may require 4GB+ RAM

To rebuild AI service:
```bash
docker-compose stop ai
docker-compose build --no-cache ai
docker-compose up -d ai
```

### Frontend Build Fails

If Next.js build fails:
1. **Clear cache**:
   ```bash
   cd frontend
   rm -rf .next node_modules
   npm install
   docker-compose build --no-cache frontend
   ```

2. **Check environment variables**:
   ```bash
   docker-compose exec frontend env | grep NEXT_PUBLIC
   ```

### Backend API Errors

If backend returns 500 errors:
1. **Check AI service connection**:
   ```bash
   docker-compose exec backend curl http://ai:8000/health
   ```

2. **Restart backend**:
   ```bash
   docker-compose restart backend
   ```

## Production Deployment

### Security Recommendations

1. **Use environment-specific configurations**:
   ```bash
   cp .env.example .env.production
   # Edit .env.production with production values
   ```

2. **Enable HTTPS**: Use a reverse proxy (nginx, Caddy) with SSL certificates

3. **Restrict CORS**: Update `backend/server.js` and `ai-service/app.py` to allow only specific origins

4. **Use secrets management**: Don't commit `.env` files. Use Docker secrets or cloud secret managers

### Cloud Deployment Options

#### AWS (ECS/Fargate)
1. Build and push images to ECR
2. Create ECS task definitions
3. Configure ALB for routing
4. Use Parameter Store for secrets

#### Google Cloud (Cloud Run)
1. Build and push to GCR
2. Deploy each service as a Cloud Run service
3. Use Secret Manager for API keys
4. Configure Cloud Load Balancer

#### Azure (Container Apps)
1. Push images to ACR
2. Create Container Apps
3. Use Key Vault for secrets
4. Set up Application Gateway

#### DigitalOcean (App Platform)
1. Connect GitHub repository
2. Configure build settings
3. Add environment variables
4. Deploy automatically

### Scaling Considerations

For production workloads:

1. **Horizontal scaling**: Add replicas for backend and AI services
   ```yaml
   backend:
     deploy:
       replicas: 3
   ```

2. **Load balancing**: Use nginx or cloud load balancer

3. **Caching**: Add Redis for response caching (already in docker-compose)

4. **Monitoring**: Add Prometheus + Grafana for metrics

## Maintenance

### Updating the Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up --build -d
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f ai
docker-compose logs -f frontend
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Backup Data

```bash
# Backup FAISS index
docker cp ecoai-ai-1:/app/data/climate_docs ./backup/

# Backup any user data (if applicable)
docker-compose exec backend tar -czf /tmp/backup.tar.gz /app/data
docker cp ecoai-backend-1:/tmp/backup.tar.gz ./backup/
```

## Performance Optimization

### AI Service Optimization

1. **Model caching**: Models are cached after first download
2. **Batch processing**: AI service supports batch inference
3. **GPU support**: For production, use GPU-enabled instances

### Frontend Optimization

1. **Static export** (for CDN hosting):
   ```bash
   cd frontend
   npm run build
   # Deploy .next/static to CDN
   ```

2. **Image optimization**: Already configured in Next.js

### Backend Optimization

1. **Connection pooling**: Configure Redis connection pool
2. **Response caching**: Cache frequently requested footprint calculations

## Support

For issues or questions:
- GitHub Issues: https://github.com/Utpal-Kalita/EcoAI/issues
- Project Demo: https://www.youtube.com/watch?v=E3vcWA7IbXw

---

Built with ❤️ for a sustainable future 🌍
