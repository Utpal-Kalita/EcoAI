# EcoAI Quick Reference

## 🚀 Quick Start Commands

### First Time Setup
```bash
git clone https://github.com/Utpal-Kalita/EcoAI.git
cd EcoAI
cp .env.example .env
# Edit .env with your API keys
./quick-deploy.sh
```

### Using Make
```bash
make install    # Setup environment
make validate   # Check prerequisites
make deploy     # Build and start
make test       # Run tests
```

## 📋 Common Commands

### Service Management
| Command | Description |
|---------|-------------|
| `make start` | Start all services |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `docker-compose ps` | Check service status |
| `docker-compose down` | Stop and remove containers |

### Monitoring
| Command | Description |
|---------|-------------|
| `make logs` | View last 100 lines of logs |
| `make logs-f` | Follow logs in real-time |
| `make health` | Check service health |
| `make status` | Service status overview |

### Building
| Command | Description |
|---------|-------------|
| `make rebuild` | Rebuild all images (no cache) |
| `docker-compose build` | Build all images |
| `docker-compose build --no-cache` | Clean build |

## 🔧 Troubleshooting

### Services Won't Start
```bash
docker-compose logs          # View all logs
docker-compose logs backend  # Specific service
docker-compose restart       # Restart all
```

### Reset Everything
```bash
make clean-all              # Stop and remove everything
make rebuild                # Rebuild images
make deploy                 # Deploy fresh
```

### Port Already in Use
```bash
lsof -i :3000              # Find process using port
kill -9 <PID>              # Kill process
# Or edit docker-compose.yml to use different ports
```

## 📍 Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:3000 | Main application |
| Backend | http://localhost:3001 | API server |
| AI Service | http://localhost:8000 | AI processing |
| Redis | redis://localhost:6379 | Cache |

## 🧪 Testing Endpoints

### Backend Health
```bash
curl http://localhost:3001/health
```

### AI Service Health
```bash
curl http://localhost:8000/health
```

### Test Carbon Analysis
```bash
curl -X POST http://localhost:3001/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "energy_kwh": 100,
    "miles_driven": 50,
    "meat_consumption": 5
  }'
```

## 🔐 Environment Variables

### Required Variables
```env
HF_TOKEN=your_token_here              # From huggingface.co
CEREBRAS_API_KEY=your_key_here        # From cloud.cerebras.ai
```

### Optional Variables
```env
FRONTEND_PORT=3000
BACKEND_PORT=3001
AI_SERVICE_PORT=8000
```

## 📂 Project Structure

```
EcoAI/
├── frontend/           # Next.js application
├── backend/            # Express API
├── ai-service/         # FastAPI + AI
│   ├── data/          # Climate data & FAISS index
│   ├── utils/         # Helper functions
│   └── app.py         # Main API
├── docs/              # Documentation
├── docker-compose.yml # Service orchestration
├── Makefile          # Command shortcuts
├── validate-deployment.sh
├── quick-deploy.sh
└── test-deployment.sh
```

## 🐛 Common Issues

### Issue: AI Service Slow to Start
**Solution**: Normal! AI service needs 30-60s to initialize FAISS and models.

### Issue: "Module not found" errors
**Solution**: 
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Issue: Out of memory
**Solution**: AI service needs 4GB+ RAM. Increase Docker memory limit.

### Issue: FAISS index missing
**Solution**: The Dockerfile automatically builds it. If missing:
```bash
docker-compose exec ai python preprocess.py
docker-compose restart ai
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [GETTING_STARTED.md](GETTING_STARTED.md) | First-time user guide |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Detailed deployment |
| [DOCKER.md](DOCKER.md) | Docker-specific guide |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture |

## 💡 Pro Tips

1. **Use Make**: Simplifies common tasks
   ```bash
   make help  # See all commands
   ```

2. **Check Health**: Before debugging, check service health
   ```bash
   make health
   ```

3. **Follow Logs**: Debug issues with live logs
   ```bash
   make logs-f
   ```

4. **Test After Deploy**: Always run tests
   ```bash
   make test
   ```

5. **Use Validation**: Catch issues early
   ```bash
   ./validate-deployment.sh
   ```

## 🔄 Update Workflow

```bash
git pull origin main        # Get latest code
make rebuild               # Rebuild images
make deploy                # Deploy updates
make test                  # Verify working
```

## 🎯 Development Workflow

### Frontend Development
```bash
cd frontend
npm install
npm run dev                # Runs on :3000
```

### Backend Development
```bash
cd backend
npm install
npm run dev                # Runs on :3001
```

### AI Service Development
```bash
cd ai-service
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
```

## 📊 Monitoring

### View Resource Usage
```bash
docker stats               # Live resource usage
```

### Check Disk Space
```bash
docker system df           # Docker disk usage
df -h                      # System disk usage
```

### Clean Up
```bash
docker system prune -a     # Remove unused images
docker volume prune        # Remove unused volumes
```

## 🆘 Getting Help

- **Issues**: https://github.com/Utpal-Kalita/EcoAI/issues
- **Demo**: https://www.youtube.com/watch?v=E3vcWA7IbXw
- **Docs**: Read the guides in the repo

## ⚡ Keyboard Shortcuts in Logs

When viewing logs with `docker-compose logs -f`:
- `Ctrl+C` - Stop following logs
- `Ctrl+S` - Pause scrolling
- `Ctrl+Q` - Resume scrolling

---

**Quick Deploy**: `./quick-deploy.sh` | **Full Guide**: `GETTING_STARTED.md`

Built with ❤️ for a sustainable future 🌍
