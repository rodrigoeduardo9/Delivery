#!/bin/bash
set -euo pipefail

# =============================================
# Delivery Platform - Setup Script
# =============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()   { echo -e "${YELLOW}[!]${NC} $1"; }
error()  { echo -e "${RED}[✗]${NC} $1"; }
info()   { echo -e "${BLUE}[i]${NC} $1"; }

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════╗"
echo "║     Delivery Platform - Setup Script          ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# -----------------------------------------
# Check prerequisites
# -----------------------------------------
info "Checking prerequisites..."

command -v node >/dev/null 2>&1 || { error "Node.js is required. Install from https://nodejs.org"; exit 1; }
command -v npm >/dev/null 2>&1  || { error "npm is required."; exit 1; }
command -v docker >/dev/null 2>&1 || { warn "Docker is recommended but not required for development."; }

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js 18+ is required. Current: $(node -v)"
    exit 1
fi
log "Node.js $(node -v) detected."

# -----------------------------------------
# Setup environment
# -----------------------------------------
info "Setting up environment..."

if [ ! -f .env ]; then
    cp .env.example .env
    log "Created .env file from .env.example"
    warn "Edit .env with your API keys before running in production."
else
    log ".env file already exists."
fi

# -----------------------------------------
# Install dependencies
# -----------------------------------------
info "Installing backend dependencies..."
cd backend && npm install
cd ..
log "Backend dependencies installed."

info "Installing web admin dependencies..."
cd web/admin-panel && npm install --legacy-peer-deps
cd ../..
log "Web admin dependencies installed."

# -----------------------------------------
# Create required directories
# -----------------------------------------
info "Creating required directories..."
mkdir -p backend/uploads
mkdir -p docker/secrets
mkdir -p docker/ssl
log "Directories created."

# -----------------------------------------
# Setup FCM placeholder
# -----------------------------------------
if [ ! -f docker/secrets/fcm_service_account.json ]; then
    echo '{}' > docker/secrets/fcm_service_account.json
    warn "Created empty FCM service account file. Replace with your Firebase credentials."
fi

# -----------------------------------------
# Start development databases
# -----------------------------------------
info "Starting development databases with Docker..."
if command -v docker >/dev/null 2>&1; then
    docker compose up -d postgres redis 2>/dev/null || {
        warn "Could not start Docker containers. Ensure Docker is running."
        warn "You'll need to start PostgreSQL and Redis manually."
    }
    log "Databases started."
else
    warn "Docker not found. Start PostgreSQL and Redis manually."
fi

# -----------------------------------------
# Database setup
# -----------------------------------------
info "Setting up database..."
sleep 3  # Wait for PostgreSQL to be ready

# Run schema
if command -v psql >/dev/null 2>&1; then
    export $(grep -v '^#' .env | xargs)
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f backend/src/database/schema.sql 2>/dev/null && \
        log "Database schema applied." || \
        warn "Could not apply schema automatically. Apply manually from backend/src/database/schema.sql"
else
    warn "psql not found. Apply schema manually from backend/src/database/schema.sql"
fi

# -----------------------------------------
# Success
# -----------------------------------------
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║        Setup Complete!                        ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "  Backend API:  http://localhost:${BACKEND_PORT:-3000}"
echo "  Admin Panel:  http://localhost:${ADMIN_PORT:-5173}"
echo ""
echo "  Commands:"
echo "    make dev          Start all development servers"
echo "    make docker-up    Start production with Docker"
echo "    make test         Run tests"
echo "    make build        Build for production"
echo ""
echo "  Mobile Apps (Flutter):"
echo "    cd mobile/client_app && flutter run"
echo "    cd mobile/driver_app && flutter run"
echo ""
