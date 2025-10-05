#!/bin/bash

# EcoAI Quick Deploy Script
# One-command deployment for EcoAI application

set -e

echo "🌍 EcoAI Quick Deploy"
echo "===================="
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file and add your API keys:"
    echo "   - HF_TOKEN (from https://huggingface.co/settings/tokens)"
    echo "   - CEREBRAS_API_KEY (from https://cloud.cerebras.ai/)"
    echo ""
    echo "After adding your keys, run this script again:"
    echo "   ./quick-deploy.sh"
    exit 1
fi

# Validate deployment
echo "🔍 Validating deployment prerequisites..."
./validate-deployment.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Validation failed. Please fix the issues and try again."
    exit 1
fi

echo ""
echo "🚀 Starting deployment..."
echo ""

# Stop existing containers if any
echo "🛑 Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build and start services
echo ""
echo "🏗️  Building Docker images..."
docker-compose build --no-cache

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service health
echo ""
echo "🏥 Checking service health..."

check_service() {
    SERVICE=$1
    URL=$2
    MAX_RETRIES=30
    RETRY=0
    
    while [ $RETRY -lt $MAX_RETRIES ]; do
        if curl -sf "$URL" > /dev/null 2>&1; then
            echo "✅ $SERVICE is healthy"
            return 0
        fi
        RETRY=$((RETRY + 1))
        echo "⏳ Waiting for $SERVICE... ($RETRY/$MAX_RETRIES)"
        sleep 2
    done
    
    echo "❌ $SERVICE failed to start"
    return 1
}

SERVICES_OK=true

if ! check_service "Backend" "http://localhost:3001/health"; then
    SERVICES_OK=false
fi

if ! check_service "AI Service" "http://localhost:8000/health"; then
    echo "⚠️  AI Service is not responding (it may need more time to initialize)"
    echo "   The application will work with fallback mode"
fi

if ! check_service "Frontend" "http://localhost:3000"; then
    SERVICES_OK=false
fi

echo ""
if [ "$SERVICES_OK" = true ]; then
    echo "=============================="
    echo "✅ EcoAI is running!"
    echo "=============================="
    echo ""
    echo "📱 Access the application:"
    echo "   Frontend:  http://localhost:3000"
    echo "   Backend:   http://localhost:3001"
    echo "   AI Service: http://localhost:8000"
    echo ""
    echo "📊 View logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 Stop services:"
    echo "   docker-compose down"
    echo ""
else
    echo "=============================="
    echo "⚠️  Some services failed to start"
    echo "=============================="
    echo ""
    echo "Check logs for details:"
    echo "   docker-compose logs"
    echo ""
    echo "Restart failed services:"
    echo "   docker-compose restart"
    exit 1
fi
