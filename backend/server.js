const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
dotenv.config();

const app = express();
const PORT = 3001;

// Middleware
app.use(cors({ origin: "*" }));
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

// Fallback plan when AI service is unavailable
function generateFallbackPlan(footprint) {
  const plans = [
    "* Reduce energy consumption by switching to LED bulbs and unplugging devices when not in use",
    "* Consider carpooling or using public transportation to reduce travel emissions",
    "* Adopt a plant-based diet 2-3 days per week to lower food-related carbon footprint",
    "* Install a programmable thermostat to optimize heating and cooling",
    "* Switch to renewable energy providers if available in your area",
  ];
  return plans.join("\n");
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

    let plan = [];
    let simulation = {};

    try {
      // Try to connect to AI service
      const apiResponse = await fetch(`${aiUrl}/process`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(req.body),
      });

      if (apiResponse.ok) {
        const apiData = await apiResponse.json();
        console.log("API Data:", apiData);

        // Extract data from AI service response
        plan = apiData.plan;
        simulation = apiData.simulation;
      } else {
        console.warn("AI service returned non-OK status, using fallback");
        plan = generateFallbackPlan(footprint);
        simulation = generateSimulation(footprint, {});
      }
    } catch (error) {
      console.warn("AI service unavailable, using fallback:", error.message);
      plan = generateFallbackPlan(footprint);
      simulation = generateSimulation(footprint, {});
    }

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

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", message: "EcoAI backend is running" });
});

app.listen(PORT, () => {
  console.log(`🌍 EcoAI backend running on http://localhost:${PORT}`);
  console.log(`📊 API endpoint: http://localhost:${PORT}/analyze`);
});
