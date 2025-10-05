#!/bin/bash

# EcoAI Deployment Validation Script
# This script checks prerequisites before deploying the application

set -e

echo "🌍 EcoAI Deployment Validator"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track errors
ERRORS=0
WARNINGS=0

# Check Docker
echo "📦 Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker found: $DOCKER_VERSION"
else
    echo -e "${RED}✗${NC} Docker not found. Please install Docker."
    ERRORS=$((ERRORS + 1))
fi

# Check Docker Compose
echo ""
echo "🐳 Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✓${NC} Docker Compose found: $COMPOSE_VERSION"
elif docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    echo -e "${GREEN}✓${NC} Docker Compose (v2) found: $COMPOSE_VERSION"
else
    echo -e "${RED}✗${NC} Docker Compose not found. Please install Docker Compose."
    ERRORS=$((ERRORS + 1))
fi

# Check .env file
echo ""
echo "🔐 Checking environment configuration..."
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env file found"
    
    # Check for required variables
    if grep -q "HF_TOKEN=" .env && ! grep -q "HF_TOKEN=$" .env && ! grep -q "HF_TOKEN= *$" .env; then
        echo -e "${GREEN}✓${NC} HF_TOKEN is configured"
    else
        echo -e "${YELLOW}⚠${NC} HF_TOKEN is not set in .env file"
        echo "  Get your token from: https://huggingface.co/settings/tokens"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if grep -q "CEREBRAS_API_KEY=" .env && ! grep -q "CEREBRAS_API_KEY=$" .env && ! grep -q "CEREBRAS_API_KEY= *$" .env; then
        echo -e "${GREEN}✓${NC} CEREBRAS_API_KEY is configured"
    else
        echo -e "${YELLOW}⚠${NC} CEREBRAS_API_KEY is not set in .env file"
        echo "  Get your API key from: https://cloud.cerebras.ai/"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} .env file not found"
    echo "  Run: cp .env.example .env"
    echo "  Then edit .env and add your API keys"
    ERRORS=$((ERRORS + 1))
fi

# Check port availability
echo ""
echo "🔌 Checking port availability..."
check_port() {
    PORT=$1
    SERVICE=$2
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}⚠${NC} Port $PORT ($SERVICE) is already in use"
        echo "  Current process: $(lsof -Pi :$PORT -sTCP:LISTEN | tail -n 1)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓${NC} Port $PORT ($SERVICE) is available"
    fi
}

check_port 3000 "Frontend"
check_port 3001 "Backend"
check_port 8000 "AI Service"
check_port 6379 "Redis"

# Check Docker daemon
echo ""
echo "🚀 Checking Docker daemon..."
if docker info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker daemon is running"
else
    echo -e "${RED}✗${NC} Docker daemon is not running"
    echo "  Start Docker and try again"
    ERRORS=$((ERRORS + 1))
fi

# Check disk space
echo ""
echo "💾 Checking disk space..."
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -gt 5 ]; then
    echo -e "${GREEN}✓${NC} Sufficient disk space available (${AVAILABLE_SPACE}GB)"
else
    echo -e "${YELLOW}⚠${NC} Low disk space (${AVAILABLE_SPACE}GB available)"
    echo "  Recommended: At least 5GB free for Docker images"
    WARNINGS=$((WARNINGS + 1))
fi

# Check data files
echo ""
echo "📚 Checking AI service data files..."
if [ -d "ai-service/data" ]; then
    if [ -f "ai-service/data/ipcc_wg3.pdf" ]; then
        echo -e "${GREEN}✓${NC} IPCC data file found"
    else
        echo -e "${YELLOW}⚠${NC} ai-service/data/ipcc_wg3.pdf not found"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if [ -f "ai-service/data/epa_factors.csv" ]; then
        echo -e "${GREEN}✓${NC} EPA factors file found"
    else
        echo -e "${YELLOW}⚠${NC} ai-service/data/epa_factors.csv not found"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} ai-service/data directory not found"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "=============================="
echo "📊 Validation Summary"
echo "=============================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You can now deploy the application:"
    echo "  docker-compose up --build -d"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo ""
    echo "You can deploy, but some features may not work optimally."
    echo "To deploy anyway:"
    echo "  docker-compose up --build -d"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found${NC}"
    echo ""
    echo "Please fix the errors before deploying."
    exit 1
fi
