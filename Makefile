.PHONY: help install dev build test lint clean docker-up docker-down docker-build db-migrate db-seed deploy

SHELL := /bin/bash

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =============================================
# Development
# =============================================

install: ## Install all dependencies
	@echo "Installing backend dependencies..."
	cd backend && npm install
	@echo "Installing web admin dependencies..."
	cd web/admin-panel && npm install --legacy-peer-deps
	@echo "Installing Flutter dependencies..."
	cd mobile/client_app && flutter pub get
	cd mobile/driver_app && flutter pub get
	@echo "All dependencies installed."

dev: ## Start development servers
	@echo "Starting PostgreSQL and Redis..."
	docker compose up -d postgres redis
	@echo "Waiting for databases..."
	@sleep 5
	@echo "Starting backend..."
	cd backend && npm run dev &
	@echo "Starting web admin..."
	cd web/admin-panel && npm run dev &
	@echo "Development servers started."
	@echo "Backend: http://localhost:3000"
	@echo "Admin:   http://localhost:5173"
	@wait

dev-backend: ## Start only backend dev server
	cd backend && npm run dev

dev-web: ## Start only web admin dev server
	cd web/admin-panel && npm run dev

dev-client: ## Start Flutter client app
	cd mobile/client_app && flutter run

dev-driver: ## Start Flutter driver app
	cd mobile/driver_app && flutter run

# =============================================
# Building
# =============================================

build: ## Build all services
	@echo "Building backend..."
	cd backend && npm run build
	@echo "Building web admin..."
	cd web/admin-panel && npm run build
	@echo "Build complete."

build-backend: ## Build only backend
	cd backend && npm run build

build-web: ## Build only web admin
	cd web/admin-panel && npm run build

# =============================================
# Testing
# =============================================

test: ## Run all tests
	cd backend && npm test

test-backend: ## Run backend tests
	cd backend && npm test

test-e2e: ## Run end-to-end tests
	cd backend && npm run test:e2e

# =============================================
# Linting
# =============================================

lint: ## Lint all code
	cd backend && npm run lint

# =============================================
# Docker
# =============================================

docker-up: ## Start all Docker containers
	docker compose up -d

docker-down: ## Stop all Docker containers
	docker compose down

docker-build: ## Build all Docker images
	docker compose build

docker-logs: ## Show logs from all containers
	docker compose logs -f

docker-reset: ## Reset all containers and volumes
	docker compose down -v
	docker compose up -d

docker-backend: ## Start only backend with dependencies
	docker compose up -d postgres redis backend

# =============================================
# Database
# =============================================

db-migrate: ## Run database migrations
	cd backend && npm run migration:run

db-seed: ## Seed database with sample data
	cd backend && npm run seed

db-reset: ## Reset database (drop, create, migrate, seed)
	cd backend && npm run migration:drop && npm run migration:run && npm run seed

db-connect: ## Connect to PostgreSQL
	docker compose exec postgres psql -U delivery_user -d delivery_db

# =============================================
# Deployment
# =============================================

deploy: ## Deploy to production (requires AWS CLI + Terraform)
	@echo "Deploying to production..."
	cd infrastructure/terraform && terraform apply -auto-approve
	@echo "Deployment complete."

deploy-backend: ## Deploy only backend
	@echo "Building and pushing backend image..."
	docker build -t delivery-backend:latest ./backend
	docker tag delivery-backend:latest $$AWS_ACCOUNT.dkr.ecr.$$AWS_REGION.amazonaws.com/delivery-backend:latest
	docker push $$AWS_ACCOUNT.dkr.ecr.$$AWS_REGION.amazonaws.com/delivery-backend:latest
	aws ecs update-service --cluster delivery-cluster --service backend-service --force-new-deployment

# =============================================
# Utilities
# =============================================

clean: ## Clean build artifacts
	rm -rf backend/dist
	rm -rf web/admin-panel/dist
	rm -rf mobile/client_app/build
	rm -rf mobile/driver_app/build
	rm -rf **/node_modules/
	@echo "Cleaned all build artifacts."

prune: ## Prune Docker system
	docker system prune -f

backup-db: ## Backup PostgreSQL database
	docker compose exec postgres pg_dump -U delivery_user delivery_db > backup_$$(date +%Y%m%d_%H%M%S).sql
