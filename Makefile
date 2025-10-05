# Makefile for EcoAI Deployment
# Provides convenient commands for managing the application

.PHONY: help install validate deploy start stop restart logs logs-follow test clean rebuild health status

# Default target
help:
	@echo "EcoAI Deployment Commands"
	@echo "========================="
	@echo ""
	@echo "Setup & Deployment:"
	@echo "  make install    - Install prerequisites and setup environment"
	@echo "  make validate   - Validate deployment prerequisites"
	@echo "  make deploy     - Build and deploy all services"
	@echo "  make quick      - Quick deploy (validate + deploy)"
	@echo ""
	@echo "Service Management:"
	@echo "  make start      - Start all services"
	@echo "  make stop       - Stop all services"
	@echo "  make restart    - Restart all services"
	@echo "  make rebuild    - Rebuild all Docker images"
	@echo ""
	@echo "Monitoring:"
	@echo "  make logs       - View logs from all services"
	@echo "  make logs-f     - Follow logs in real-time"
	@echo "  make health     - Check health of all services"
	@echo "  make status     - Check status of all services"
	@echo "  make test       - Run deployment tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean      - Stop services and remove containers"
	@echo "  make clean-all  - Clean everything including volumes"
	@echo "  make update     - Pull latest changes and redeploy"
	@echo ""

# Setup environment
install:
	@echo "Setting up EcoAI environment..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✓ Created .env file. Please edit it with your API keys."; \
	else \
		echo "✓ .env file already exists"; \
	fi
	@chmod +x validate-deployment.sh quick-deploy.sh test-deployment.sh
	@echo "✓ Made scripts executable"
	@echo ""
	@echo "Next steps:"
	@echo "1. Edit .env and add your API keys (HF_TOKEN, CEREBRAS_API_KEY)"
	@echo "2. Run: make validate"
	@echo "3. Run: make deploy"

# Validate deployment
validate:
	@echo "Validating deployment prerequisites..."
	@./validate-deployment.sh

# Deploy (build and start)
deploy: validate
	@echo "Building and deploying EcoAI..."
	@docker-compose build
	@docker-compose up -d
	@echo ""
	@echo "✓ Deployment complete!"
	@echo "Services are starting up..."
	@sleep 10
	@$(MAKE) health

# Quick deploy using script
quick:
	@./quick-deploy.sh

# Start services
start:
	@echo "Starting EcoAI services..."
	@docker-compose up -d
	@echo "✓ Services started"
	@$(MAKE) status

# Stop services
stop:
	@echo "Stopping EcoAI services..."
	@docker-compose stop
	@echo "✓ Services stopped"

# Restart services
restart:
	@echo "Restarting EcoAI services..."
	@docker-compose restart
	@echo "✓ Services restarted"
	@$(MAKE) status

# View logs
logs:
	@docker-compose logs --tail=100

# Follow logs
logs-f:
	@docker-compose logs -f

# Check health
health:
	@echo "Checking service health..."
	@echo ""
	@echo "Backend:"
	@curl -sf http://localhost:3001/health | python3 -m json.tool || echo "  ✗ Not responding"
	@echo ""
	@echo "AI Service:"
	@curl -sf http://localhost:8000/health | python3 -m json.tool || echo "  ✗ Not responding"
	@echo ""
	@echo "Frontend:"
	@curl -sf http://localhost:3000 > /dev/null && echo "  ✓ Responding" || echo "  ✗ Not responding"

# Check status
status:
	@echo "Service Status:"
	@docker-compose ps

# Run tests
test:
	@./test-deployment.sh

# Clean (remove containers)
clean:
	@echo "Cleaning up containers..."
	@docker-compose down
	@echo "✓ Containers removed"

# Clean all (including volumes)
clean-all:
	@echo "Cleaning up everything..."
	@docker-compose down -v
	@echo "✓ Containers and volumes removed"

# Rebuild images
rebuild:
	@echo "Rebuilding Docker images..."
	@docker-compose build --no-cache
	@echo "✓ Images rebuilt"

# Update (pull latest code and redeploy)
update:
	@echo "Updating EcoAI..."
	@git pull origin main
	@$(MAKE) rebuild
	@$(MAKE) deploy
	@echo "✓ Update complete"

# Development commands
dev-frontend:
	@echo "Starting frontend in development mode..."
	@cd frontend && npm run dev

dev-backend:
	@echo "Starting backend in development mode..."
	@cd backend && npm run dev

dev-ai:
	@echo "Starting AI service in development mode..."
	@cd ai-service && uvicorn app:app --reload --port 8000

# Docker commands
docker-ps:
	@docker-compose ps

docker-logs:
	@docker-compose logs

docker-exec-backend:
	@docker-compose exec backend sh

docker-exec-frontend:
	@docker-compose exec frontend sh

docker-exec-ai:
	@docker-compose exec ai bash

# Show URLs
urls:
	@echo "EcoAI Application URLs:"
	@echo "======================="
	@echo "Frontend:   http://localhost:3000"
	@echo "Backend:    http://localhost:3001"
	@echo "AI Service: http://localhost:8000"
	@echo "Redis:      redis://localhost:6379"
