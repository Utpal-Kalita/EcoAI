# EcoAI Deployment Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          USER                                    │
│                            │                                     │
│                            ▼                                     │
│                    http://localhost:3000                         │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       FRONTEND                                   │
│                     (Next.js 14)                                 │
│                      Port: 3000                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • Carbon Footprint Calculator Form                        │ │
│  │  • Interactive Dashboard & Charts                          │ │
│  │  • PDF Export Functionality                                │ │
│  │  • Responsive UI with Tailwind CSS                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP POST /analyze
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       BACKEND                                    │
│                  (Express/Node.js 20)                            │
│                      Port: 3001                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • API Endpoint: /analyze                                  │ │
│  │  • Carbon Footprint Calculation                            │ │
│  │  • Request Validation                                      │ │
│  │  • AI Service Integration                                  │ │
│  │  • Fallback Mode (if AI unavailable)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP POST /process
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AI SERVICE                                   │
│                   (FastAPI/Python 3.10)                          │
│                      Port: 8000                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • Llama 3.1 (Hugging Face)                                │ │
│  │  • Cerebras SDK (Fast Inference)                           │ │
│  │  • FAISS Vector Store (Climate Data)                       │ │
│  │  • RAG Chain (Retrieval-Augmented Generation)              │ │
│  │  • Personalized Sustainability Plans                       │ │
│  │  • What-If Simulations                                     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ Query
                             ▼
                    ┌────────────────┐
                    │  FAISS Index   │
                    │ (Climate Docs) │
                    └────────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
            ┌───────▼──────┐  ┌──────▼───────┐
            │ IPCC Report  │  │  EPA Factors │
            │    (PDF)     │  │     (CSV)    │
            └──────────────┘  └──────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         REDIS                                    │
│                   (Cache & Session)                              │
│                      Port: 6379                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  • Response Caching                                        │ │
│  │  • Session Storage                                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### User Request Flow
```
1. User enters habits → Frontend Form
2. Frontend validates → POST to Backend (/analyze)
3. Backend calculates → Basic carbon footprint
4. Backend requests → AI Service (/process)
5. AI Service uses → RAG Chain with FAISS
6. AI Service generates → Personalized plan
7. AI Service runs → What-if simulation
8. Backend formats → Response with breakdown
9. Frontend displays → Results + Charts
```

### AI Processing Flow
```
User Input
    ↓
Backend API
    ↓
AI Service
    ↓
┌─────────────┐
│ Calculate   │ → Basic footprint calculation
│ Footprint   │
└─────────────┘
    ↓
┌─────────────┐
│ RAG Query   │ → Query FAISS vector store
└─────────────┘    with climate data
    ↓
┌─────────────┐
│ Llama 3.1   │ → Generate personalized plan
│ (Cerebras)  │    (accelerated inference)
└─────────────┘
    ↓
┌─────────────┐
│ Simulation  │ → Run what-if scenarios
└─────────────┘
    ↓
Response
```

## Docker Network Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Docker Network: ecoai-net                 │
│                         (Bridge Mode)                         │
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐ │
│  │   Frontend   │─────▶│   Backend    │─────▶│    AI     │ │
│  │   :3000      │      │   :3001      │      │  :8000    │ │
│  └──────────────┘      └──────────────┘      └───────────┘ │
│         │                      │                            │
│         │                      │                            │
│         │              ┌───────▼────────┐                   │
│         │              │     Redis      │                   │
│         │              │     :6379      │                   │
│         │              └────────────────┘                   │
│         │                                                    │
└─────────┼────────────────────────────────────────────────────┘
          │
          │ (Port Mapping)
          ▼
    Host Machine
    localhost:3000

Service Communication:
- Frontend → Backend: http://backend:3001
- Backend → AI: http://ai:8000
- Backend → Redis: redis://redis:6379
```

## Deployment Methods

### Method 1: Quick Deploy Script (Recommended)
```
./quick-deploy.sh
    ↓
Validates Prerequisites
    ↓
Checks .env File
    ↓
Builds Docker Images
    ↓
Starts Services
    ↓
Waits for Health Checks
    ↓
Reports Status
```

### Method 2: Using Makefile
```
make quick
    ↓
make validate
    ↓
make deploy
    ↓
make test
```

### Method 3: Docker Compose
```
docker-compose build
    ↓
docker-compose up -d
    ↓
docker-compose ps
```

## Health Check Flow

```
Docker Compose Starts Services
    ↓
Each Service Runs Health Check
    ↓
┌─────────────────────────────────────┐
│ Frontend: curl localhost:3000       │ Every 30s
│ Backend: curl localhost:3001/health │ Every 30s
│ AI: curl localhost:8000/health      │ Every 30s
│ Redis: redis-cli ping               │ Every 10s
└─────────────────────────────────────┘
    ↓
If Healthy → Service Ready
If Unhealthy → Service Restarts
```

## Fallback Mechanisms

### AI Service Unavailable
```
User Request → Backend
    ↓
Backend tries AI Service
    ↓
AI Service Down/Timeout
    ↓
Backend uses Fallback:
- Static carbon calculations
- Pre-defined sustainability tips
- Random simulation scenarios
    ↓
Response still provided to user
```

### RAG Chain Initialization Failure
```
AI Service Starts
    ↓
RAG Chain Setup Fails
(Missing API keys or FAISS index)
    ↓
AI Service runs in Degraded Mode:
- Basic footprint calculation
- Fallback plan generation
- Simple simulations
    ↓
Service still functional
```

## Scalability Options

### Horizontal Scaling
```
                    Load Balancer
                         │
        ┌────────────────┼────────────────┐
        │                │                │
    Backend 1        Backend 2        Backend 3
        │                │                │
        └────────────────┼────────────────┘
                         │
                      AI Service
```

### Resource Allocation
```
Frontend:  0.5 CPU, 512MB RAM
Backend:   1 CPU,   1GB RAM
AI:        2 CPU,   4GB RAM
Redis:     0.5 CPU, 256MB RAM
```

## Production Deployment Architecture

```
                    Internet
                       │
                       ▼
                  CloudFlare CDN
                       │
                       ▼
                  Load Balancer
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    Frontend       Backend        AI Service
    (Container)  (Container)    (Container)
        │              │              │
        └──────────────┼──────────────┘
                       │
                    Redis
                  (Managed)
```

## Security Layers

```
1. Network Level
   └─ Docker Bridge Network (Isolated)

2. Application Level
   ├─ CORS Configuration
   ├─ Request Validation
   └─ Error Handling

3. Data Level
   ├─ Environment Variables (Secrets)
   ├─ No Hardcoded Credentials
   └─ API Key Management

4. Infrastructure Level
   ├─ Health Checks
   ├─ Auto-restart Policies
   └─ Resource Limits
```

---

Built with ❤️ for a sustainable future 🌍
