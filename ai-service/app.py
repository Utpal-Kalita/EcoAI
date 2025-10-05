import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from utils.rag_chain import setup_rag_chain
from utils.footprint_calc import calculate_footprint
from utils.simulations import run_simulation

load_dotenv()
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001", "http://frontend:3000", "http://backend:3001"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize RAG chain globally
rag_chain = None

@app.on_event("startup")
async def startup_event():
    """Initialize RAG chain on startup"""
    global rag_chain
    try:
        rag_chain = setup_rag_chain()
        print("✅ RAG chain initialized successfully")
    except Exception as e:
        print(f"⚠️ Warning: Could not initialize RAG chain: {e}")
        print("AI service will run in degraded mode")

class UserData(BaseModel):
    energy_kwh: float = 0.0
    miles_driven: float = 0.0
    meat_consumption: float = 0.0
    scenario: str = "none"

@app.get("/health")
async def health_check():
    """Health check endpoint for Docker"""
    status = {
        "status": "healthy",
        "service": "ecoai-ai-service",
        "model": "llama3.1-8b",
        "rag_initialized": rag_chain is not None
    }
    return status

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "EcoAI AI Service",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "process": "/process (POST)"
        }
    }

@app.post("/process")
async def process_data(data: UserData):
    try:
        # Calculate footprint
        footprint = calculate_footprint(data.dict())
        
        # Generate plan using RAG if available
        if rag_chain:
            try:
                query = f"Provide a sustainability plan to reduce a carbon footprint of {footprint['total_co2']:.2f} tons CO2. Give 5 specific actionable recommendations."
                plan = rag_chain.run(query)
            except Exception as e:
                print(f"RAG error: {e}")
                plan = generate_fallback_plan(footprint['total_co2'])
        else:
            plan = generate_fallback_plan(footprint['total_co2'])
        
        # Run simulation
        simulation = run_simulation(footprint["total_co2"], data.scenario)
        
        return {
            "footprint": footprint,
            "plan": plan,
            "simulation": simulation
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def generate_fallback_plan(total_co2: float) -> str:
    """Generate a simple fallback plan when RAG is unavailable"""
    plans = [
        "* Reduce energy consumption by switching to LED bulbs and unplugging devices when not in use",
        "* Consider carpooling or using public transportation to reduce travel emissions",
        "* Adopt a plant-based diet 2-3 days per week to lower food-related carbon footprint",
        "* Install a programmable thermostat to optimize heating and cooling",
        "* Switch to renewable energy providers if available in your area"
    ]
    return "\n".join(plans)