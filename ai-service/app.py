import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from utils.rag_chain import setup_rag_chain
from utils.footprint_calc import calculate_footprint
from utils.simulations import run_simulation

load_dotenv()
app = FastAPI(title="EcoAI AI Service", version="1.0.0")

# CORS Configuration for production
allowed_origins = [
    "http://localhost:3000",
    "http://localhost:3001",
    "https://localhost:3000",
    "https://localhost:3001",
]

# Add production URLs from environment if available
if os.getenv("FRONTEND_URL"):
    allowed_origins.append(os.getenv("FRONTEND_URL"))
if os.getenv("BACKEND_URL"):
    allowed_origins.append(os.getenv("BACKEND_URL"))

# Add Vercel and Render URL patterns
allowed_origin_patterns = [
    r"https://.*\.vercel\.app",
    r"https://.*\.onrender\.com",
    r"https://ecoai.*\.vercel\.app",
]

import re

def check_origin(origin: str) -> bool:
    """Check if origin is allowed based on exact match or pattern"""
    if origin in allowed_origins:
        return True
    for pattern in allowed_origin_patterns:
        if re.match(pattern, origin):
            return True
    return False

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https://.*\.(vercel\.app|onrender\.com)",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
rag_chain = setup_rag_chain()

class UserData(BaseModel):
    energy_kwh: float = 0.0
    miles_driven: float = 0.0
    meat_consumption: float = 0.0
    scenario: str = "none"

@app.post("/process")
async def process_data(data: UserData):
    try:
        # Calculate footprint
        footprint = calculate_footprint(data.dict())
        
        # Generate plan using RAG
        query = f"Provide a sustainability plan to reduce a carbon footprint of {footprint['total_co2']} tons CO2."
        plan = rag_chain.run(query)
        
        # Run simulation
        simulation = run_simulation(footprint["total_co2"], data.scenario)
        
        return {
            "footprint": footprint,
            "plan": plan,
            "simulation": simulation
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring service status"""
    import time
    return {
        "status": "ok",
        "message": "EcoAI AI Service is running",
        "timestamp": time.time(),
        "service": "ai-service",
        "version": "1.0.0"
    }

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "name": "EcoAI AI Service",
        "version": "1.0.0",
        "description": "AI-powered carbon footprint analysis with Llama 3.1 and Cerebras",
        "endpoints": {
            "health": "/health",
            "process": "POST /process"
        }
    }