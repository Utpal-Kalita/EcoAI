# Docker Deployment Guide for EcoAI

This guide focuses specifically on deploying EcoAI using Docker and Docker Compose.

## Quick Start

```bash
# 1. Clone and navigate to the repository
git clone https://github.com/Utpal-Kalita/EcoAI.git
cd EcoAI

# 2. Run the quick deploy script
./quick-deploy.sh
```

That's it! The script will handle everything for you.

## Manual Deployment Steps

### Prerequisites

- Docker 20.10+ installed
- Docker Compose 2.0+ installed
- At least 5GB free disk space
- Ports 3000, 3001, 8000, and 6379 available

### Step 1: Environment Configuration

```bash
# Copy the environment template
cp .env.example .env

# Edit the .env file and add your API keys
nano .env  # or use your preferred editor
```

Required variables:
- `HF_TOKEN`: Your Hugging Face token ([Get it here](https://huggingface.co/settings/tokens))
- `CEREBRAS_API_KEY`: Your Cerebras API key ([Get it here](https://cloud.cerebras.ai/))

### Step 2: Validate Configuration

```bash
# Run the validation script
./validate-deployment.sh
```

This checks:
- ✅ Docker and Docker Compose installation
- ✅ Environment variables configuration
- ✅ Port availability
- ✅ Data files presence
- ✅ Disk space

### Step 3: Build and Deploy

```bash
# Build all images
docker-compose build

# Start all services in detached mode
docker-compose up -d

# Check service status
docker-compose ps
```

### Step 4: Verify Deployment

```bash
# Run automated tests
./test-deployment.sh

# Or manually check each service:
curl http://localhost:3001/health  # Backend
curl http://localhost:8000/health  # AI Service
curl http://localhost:3000         # Frontend
```

### Step 5: Access the Application

Open your browser and navigate to:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **AI Service**: http://localhost:8000

## Docker Architecture

### Services Overview

```
┌─────────────────────────────────────────────────┐
│                   EcoAI Stack                   │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│  │ Frontend │───▶│ Backend  │───▶│    AI    │ │
│  │  :3000   │    │  :3001   │    │  :8000   │ │
│  └──────────┘    └──────────┘    └──────────┘ │
│                         │                       │
│                         ▼                       │
│                  ┌──────────┐                   │
│                  │  Redis   │                   │
│                  │  :6379   │                   │
│                  └──────────┘                   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Service Details

#### Frontend (Next.js)
- **Image**: Custom build from `frontend/Dockerfile`
- **Port**: 3000
- **Dependencies**: Backend service
- **Health Check**: HTTP GET to `/`

#### Backend (Express)
- **Image**: Custom build from `backend/Dockerfile`
- **Port**: 3001
- **Dependencies**: AI service, Redis
- **Health Check**: HTTP GET to `/health`

#### AI Service (FastAPI)
- **Image**: Custom build from `ai-service/Dockerfile`
- **Port**: 8000
- **Dependencies**: None (standalone)
- **Health Check**: HTTP GET to `/health`
- **Features**:
  - Llama 3.1 integration
  - Cerebras-accelerated inference
  - FAISS vector search
  - RAG-based recommendations

#### Redis
- **Image**: `redis:alpine`
- **Port**: 6379
- **Purpose**: Caching and session storage
- **Health Check**: `redis-cli ping`

### Network Configuration

All services are connected via the `ecoai-net` bridge network, enabling inter-service communication using service names as hostnames.

## Docker Commands Reference

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d frontend

# Start without rebuilding
docker-compose up -d --no-build

# Start with live logs
docker-compose up
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop backend
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f ai

# Last 100 lines
docker-compose logs --tail=100
```

### Building Images

```bash
# Build all images
docker-compose build

# Build without cache (clean build)
docker-compose build --no-cache

# Build specific service
docker-compose build frontend
```

### Managing Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend

# Check service status
docker-compose ps

# View resource usage
docker stats
```

### Debugging

```bash
# Execute command in running container
docker-compose exec backend sh
docker-compose exec ai bash

# View container logs
docker logs ecoai-frontend
docker logs ecoai-backend
docker logs ecoai-ai-service

# Inspect container
docker inspect ecoai-backend
```

## Troubleshooting

### Issue: Services Won't Start

**Solution 1**: Check logs
```bash
docker-compose logs
```

**Solution 2**: Rebuild images
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Issue: Port Already in Use

**Find the process**:
```bash
lsof -i :3000  # or :3001, :8000
```

**Kill the process**:
```bash
kill -9 <PID>
```

**Or change ports** in `docker-compose.yml` and `.env` files.

### Issue: AI Service Fails to Start

**Check if API keys are set**:
```bash
docker-compose exec ai env | grep -E "HF_TOKEN|CEREBRAS"
```

**View AI service logs**:
```bash
docker-compose logs ai
```

**Common causes**:
1. Missing API keys in `.env`
2. Invalid API keys
3. FAISS index build failure
4. Insufficient memory (AI service needs 4GB+ RAM)

### Issue: Frontend Can't Connect to Backend

**Check network connectivity**:
```bash
docker-compose exec frontend wget -O- http://backend:3001/health
```

**Verify environment variables**:
```bash
docker-compose exec frontend env | grep NEXT_PUBLIC_API_URL
```

### Issue: Out of Disk Space

**Clean up Docker**:
```bash
# Remove unused containers, networks, images
docker system prune -a

# Remove unused volumes
docker volume prune

# Check disk usage
docker system df
```

## Advanced Configuration

### Custom Environment Variables

Create a `docker-compose.override.yml` file:

```yaml
version: "3.8"
services:
  backend:
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
  
  frontend:
    environment:
      - NEXT_PUBLIC_ENABLE_ANALYTICS=true
```

### Volume Mounting for Development

```yaml
services:
  backend:
    volumes:
      - ./backend:/app
      - /app/node_modules
```

### Resource Limits

```yaml
services:
  ai:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          memory: 2G
```

### Multiple Replicas

```yaml
services:
  backend:
    deploy:
      replicas: 3
```

## Production Deployment

### Using Docker Compose in Production

1. **Use production environment file**:
   ```bash
   cp .env.production.example .env.production
   docker-compose --env-file .env.production up -d
   ```

2. **Enable restart policies** (already configured):
   ```yaml
   restart: unless-stopped
   ```

3. **Use specific image tags**:
   ```yaml
   image: ecoai-frontend:1.0.0
   ```

4. **Set up reverse proxy** (nginx, Caddy, Traefik)

5. **Enable HTTPS** with Let's Encrypt

### Cloud Deployment

#### AWS ECS
```bash
# Build and push to ECR
docker-compose build
docker tag ecoai-frontend:latest <account>.dkr.ecr.region.amazonaws.com/ecoai-frontend:latest
docker push <account>.dkr.ecr.region.amazonaws.com/ecoai-frontend:latest
```

#### Google Cloud Run
```bash
# Build and push to GCR
docker-compose build
docker tag ecoai-frontend:latest gcr.io/<project>/ecoai-frontend:latest
docker push gcr.io/<project>/ecoai-frontend:latest
gcloud run deploy ecoai-frontend --image gcr.io/<project>/ecoai-frontend:latest
```

#### Azure Container Instances
```bash
# Push to ACR
docker-compose build
docker tag ecoai-frontend:latest <registry>.azurecr.io/ecoai-frontend:latest
docker push <registry>.azurecr.io/ecoai-frontend:latest
```

## Monitoring and Maintenance

### Health Monitoring

All services have built-in health checks. Check status:
```bash
docker-compose ps
```

Healthy services show `(healthy)` status.

### Log Rotation

Configure log rotation in `docker-compose.yml`:
```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Backup and Restore

**Backup FAISS index**:
```bash
docker cp ecoai-ai-service:/app/data/climate_docs ./backup/
```

**Restore FAISS index**:
```bash
docker cp ./backup/climate_docs ecoai-ai-service:/app/data/
```

## Performance Optimization

### Image Size Optimization

- ✅ Using Alpine Linux base images
- ✅ Multi-stage builds for frontend
- ✅ `.dockerignore` files to exclude unnecessary files
- ✅ `--no-cache-dir` for pip installs

### Build Cache

```bash
# Use build cache for faster builds
docker-compose build

# Skip cache for clean build
docker-compose build --no-cache
```

### Network Performance

Services communicate via internal Docker network (faster than localhost).

## Security Best Practices

1. **Never commit `.env` files** (already in `.gitignore`)
2. **Use secrets for sensitive data** in production
3. **Run containers as non-root** (to be implemented)
4. **Scan images for vulnerabilities**:
   ```bash
   docker scan ecoai-frontend
   ```
5. **Keep base images updated**
6. **Use read-only root filesystem** where possible

## Support

- **GitHub Issues**: https://github.com/Utpal-Kalita/EcoAI/issues
- **Demo Video**: https://www.youtube.com/watch?v=E3vcWA7IbXw
- **Documentation**: [DEPLOYMENT.md](DEPLOYMENT.md)

---

Built with ❤️ for a sustainable future 🌍
