const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// CORS Configuration for production
const allowedOrigins = [
  'http://localhost:3000',
  'https://localhost:3000',
  process.env.FRONTEND_URL,
  // Add your Vercel deployment URL pattern
  /^https:\/\/.*\.vercel\.app$/,
  /^https:\/\/ecoai.*\.vercel\.app$/
].filter(Boolean);

// Middleware
app.use(cors({ 
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // Check if origin is in allowed list or matches pattern
    const isAllowed = allowedOrigins.some(allowed => {
      if (typeof allowed === 'string') {
        return allowed === origin;
      }
      if (allowed instanceof RegExp) {
        return allowed.test(origin);
      }
      return false;
    });
    
    if (isAllowed) {
      callback(null, true);
    } else {
      console.log('CORS blocked origin:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Mock carbon footprint calculation
function calculateFootprint(energy_kwh, miles_driven, meat_consumption) {
  // Simple calculations (kg CO2 per year)
  const energyFootprint = energy_kwh * 52 * 0.5; // 0.5 kg CO2 per kWh
  const travelFootprint = miles_driven * 52 * 0.411; // 0.411 kg CO2 per mile
  const meatFootprint = meat_consumption * 52 * 6.61; // 6.61 kg CO2 per serving

  const total = (energyFootprint + travelFootprint + meatFootprint) / 1000; // Convert to tons

  return {
    total: total,
    energy: energyFootprint / 1000,
    travel: travelFootprint / 1000,
    food: meatFootprint / 1000,
  };
}

//  AI-generated plan
function generatePlan(responseplans) {
  const points = (responseplans.match(/^\s*\* (.+)$/gm) || []).map((p) =>
    p.replace(/^\s*\* /, "")
  );
  console.log("points came", points);
  return points.slice(0, Math.min(5, Math.ceil(points.length / 2)));
}

// Mock simulation
function generateSimulation(footprint, simulations) {
  for (let scene in simulations) {
    console.log(scene, simulations[scene]);
  }
  const scenarios = [
    {
      scenario: "Switch to electric vehicle",
      savings: footprint.travel * 0.7,
      newFootprint: footprint.total - footprint.travel * 0.7,
    },
    {
      scenario: "Reduce energy consumption by 20%",
      savings: footprint.energy * 0.2,
      newFootprint: footprint.total - footprint.energy * 0.2,
    },
    {
      scenario: "Adopt plant-based diet 3 days/week",
      savings: footprint.food * 0.4,
      newFootprint: footprint.total - footprint.food * 0.4,
    },
  ];

  return scenarios[Math.floor(Math.random() * scenarios.length)];
}

// API endpoint
app.post("/analyze", async (req, res) => {
  try {
    const { energy_kwh, miles_driven, meat_consumption } = req.body;
    // Validation
    if (!energy_kwh || !miles_driven || meat_consumption === undefined) {
      return res.status(400).json({
        error:
          "Missing required fields: energy_kwh, miles_driven, meat_consumption",
      });
    }

    // Calculate footprint
    const footprint = calculateFootprint(
      energy_kwh,
      miles_driven,
      meat_consumption
    );

    // Calculate percentages for breakdown
    const energyPercent = (footprint.energy / footprint.total) * 100;
    const travelPercent = (footprint.travel / footprint.total) * 100;
    const foodPercent = (footprint.food / footprint.total) * 100;

    const aiUrl = process.env.AI_URL || "http://localhost:8000";

    const apiResponse = await fetch(`${aiUrl}/process`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body),
    });
    const apiData = await apiResponse.json();
    console.log("API Data:", apiData);

    // Extract data from AI service response
    // const responseplans = apiData.plans
    const responsefootprint = apiData.footprint;
    const plan = apiData.plan;
    const simulation = apiData.simulation;

    // Generate response
    const response = {
      totalFootprint: parseFloat(footprint.total.toFixed(2)),
      breakdown: {
        energy: parseFloat(energyPercent.toFixed(1)),
        travel: parseFloat(travelPercent.toFixed(1)),
        food: parseFloat(foodPercent.toFixed(1)),
      },
      plan: generatePlan(plan),
      simulation: generateSimulation(footprint, simulation),
    };

    console.log("Request:", req.body);
    console.log("Response:", response);

    res.json(response);
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

// Health check endpoint with dependency status
app.get("/health", async (req, res) => {
  const health = {
    status: "ok",
    message: "EcoAI backend is running",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || "development",
  };

  // Check AI service health
  try {
    const aiUrl = process.env.AI_URL || "http://localhost:8000";
    const aiHealth = await fetch(`${aiUrl}/health`, { 
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      signal: AbortSignal.timeout(5000) // 5 second timeout
    });
    
    if (aiHealth.ok) {
      health.ai_service = "connected";
    } else {
      health.ai_service = "unreachable";
      health.status = "degraded";
    }
  } catch (error) {
    health.ai_service = "error";
    health.ai_error = error.message;
    health.status = "degraded";
  }

  const statusCode = health.status === "ok" ? 200 : 503;
  res.status(statusCode).json(health);
});

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    name: "EcoAI Backend API",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      analyze: "POST /analyze"
    }
  });
});

app.listen(PORT, () => {
  console.log(`🌍 EcoAI backend running on port ${PORT}`);
  console.log(`📊 API endpoint: http://localhost:${PORT}/analyze`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health`);
});
