# Getting Started with EcoAI

Welcome! This guide will help you get EcoAI up and running in just a few minutes.

## 🎯 What You'll Need

Before starting, make sure you have:

1. ✅ **Docker** installed ([Download Docker](https://www.docker.com/get-started))
2. ✅ **Git** installed
3. ✅ **Hugging Face Token** ([Get it here](https://huggingface.co/settings/tokens))
4. ✅ **Cerebras API Key** ([Get it here](https://cloud.cerebras.ai/))

## 🚀 Quick Start (3 Steps)

### Step 1: Clone the Repository

```bash
git clone https://github.com/Utpal-Kalita/EcoAI.git
cd EcoAI
```

### Step 2: Configure Environment

```bash
# Copy the environment template
cp .env.example .env

# Edit .env and add your API keys
nano .env  # or use your preferred editor
```

Add your keys:
```env
HF_TOKEN=your_huggingface_token_here
CEREBRAS_API_KEY=your_cerebras_api_key_here
```

### Step 3: Deploy

Choose your preferred method:

#### Option A: Using the Quick Deploy Script (Recommended)
```bash
./quick-deploy.sh
```

#### Option B: Using Make
```bash
make quick
```

#### Option C: Using Docker Compose Directly
```bash
docker-compose up --build -d
```

That's it! 🎉

## 📱 Accessing the Application

Once deployed, open your browser and visit:

- **Main Application**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **AI Service**: http://localhost:8000

## 🧪 Testing Your Deployment

Run the automated test suite:

```bash
./test-deployment.sh
```

Or test manually:

```bash
# Test backend
curl http://localhost:3001/health

# Test AI service
curl http://localhost:8000/health

# Test with sample data
curl -X POST http://localhost:3001/analyze \
  -H "Content-Type: application/json" \
  -d '{"energy_kwh": 100, "miles_driven": 50, "meat_consumption": 5}'
```

## 📖 What's Next?

### Using the Application

1. **Enter Your Habits**: On the homepage, input your:
   - Weekly energy consumption (kWh)
   - Weekly miles driven
   - Weekly meat consumption (servings)

2. **Get Your Analysis**: Submit the form to receive:
   - Your total carbon footprint
   - Breakdown by category (energy, travel, food)
   - Personalized sustainability plan
   - "What-if" simulations for greener choices

3. **Download Report**: Export your analysis as a PDF

### Exploring the Code

- **Frontend**: Next.js 14 application in `frontend/`
- **Backend**: Express API in `backend/`
- **AI Service**: FastAPI with Llama 3.1 in `ai-service/`

### Common Commands

```bash
# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart services
docker-compose restart

# Rebuild after code changes
docker-compose up --build -d
```

Or use the Makefile:

```bash
make logs-f      # Follow logs
make stop        # Stop services
make restart     # Restart services
make rebuild     # Rebuild images
```

## 🔧 Troubleshooting

### Services Won't Start

1. **Check Docker is running**:
   ```bash
   docker ps
   ```

2. **View error logs**:
   ```bash
   docker-compose logs
   ```

3. **Rebuild images**:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

### Port Conflicts

If ports 3000, 3001, or 8000 are already in use:

1. **Find what's using the port**:
   ```bash
   lsof -i :3000
   ```

2. **Stop the conflicting process** or edit `docker-compose.yml` to use different ports

### Missing API Keys

If you see errors about missing API keys:

1. Verify your `.env` file has the correct keys:
   ```bash
   cat .env | grep -E "HF_TOKEN|CEREBRAS"
   ```

2. Restart services after adding keys:
   ```bash
   docker-compose restart
   ```

### AI Service Issues

The AI service may take 30-60 seconds to fully initialize. If it's still not working:

1. Check logs:
   ```bash
   docker-compose logs ai
   ```

2. The application will work in "fallback mode" if the AI service is unavailable

## 📚 Additional Resources

- **Full Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **Docker Documentation**: [DOCKER.md](DOCKER.md)
- **Project Demo**: [Watch on YouTube](https://www.youtube.com/watch?v=E3vcWA7IbXw)
- **Architecture Overview**: See `docs/ecoAI-architecture.png`

## 🤝 Getting Help

- **Issues**: [GitHub Issues](https://github.com/Utpal-Kalita/EcoAI/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Utpal-Kalita/EcoAI/discussions)

## 💡 Tips

- The AI service needs 4GB+ RAM to run optimally
- First build may take 5-10 minutes to download dependencies
- Use `make help` to see all available commands
- Run `./validate-deployment.sh` before deploying to catch issues early

## 🌟 What Makes EcoAI Special?

- **AI-Powered**: Uses Llama 3.1 for personalized recommendations
- **Fast**: Cerebras SDK accelerates inference from 10s to <1s
- **Smart**: RAG-based recommendations using climate research data
- **Interactive**: Real-time "what-if" simulations
- **Modern Stack**: Next.js, Express, FastAPI, Docker

---

Ready to make an impact? Start reducing your carbon footprint today! 🌍

Built with ❤️ for a sustainable future
