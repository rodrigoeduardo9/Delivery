#!/bin/bash
set -euo pipefail

# =============================================
# Delivery Platform - Production Deploy Script
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

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT="${AWS_ACCOUNT:?AWS_ACCOUNT is required}"
ECR_REPO="${ECR_REPO:-delivery-platform}"
ECS_CLUSTER="${ECS_CLUSTER:-delivery-cluster}"
ECS_SERVICE_BACKEND="${ECS_SERVICE_BACKEND:-backend-service}"
ECS_SERVICE_WEB="${ECS_SERVICE_WEB:-web-admin-service}"

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════╗"
echo "║     Delivery Platform - Deploy Script         ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"

# -----------------------------------------
# Validate environment
# -----------------------------------------
info "Validating environment..."

if [ ! -f .env.production ]; then
    error ".env.production file not found. Create it from .env.example"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    error "AWS CLI is required. Install from https://aws.amazon.com/cli/"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    error "Docker is required."
    exit 1
fi

# Check AWS authentication
aws sts get-caller-identity &> /dev/null || {
    error "AWS not authenticated. Run 'aws configure' first."
    exit 1
}

log "Environment validated."

# -----------------------------------------
# Load environment
# -----------------------------------------
export $(grep -v '^#' .env.production | xargs)

# -----------------------------------------
# Login to ECR
# -----------------------------------------
info "Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
    docker login --username AWS --password-stdin "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"
log "ECR login successful."

# -----------------------------------------
# Build and push backend image
# -----------------------------------------
info "Building backend image..."
docker build \
    --platform linux/amd64 \
    -t "$ECR_REPO/backend:latest" \
    -t "$ECR_REPO/backend:$(git rev-parse --short HEAD)" \
    -f backend/Dockerfile \
    ./backend
log "Backend image built."

info "Pushing backend image..."
docker push "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO/backend:latest"
docker push "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO/backend:$(git rev-parse --short HEAD)"
log "Backend image pushed."

# -----------------------------------------
# Build and push web admin image
# -----------------------------------------
info "Building web admin image..."
docker build \
    --platform linux/amd64 \
    --build-arg VITE_API_URL="$VITE_API_URL" \
    -t "$ECR_REPO/web-admin:latest" \
    -t "$ECR_REPO/web-admin:$(git rev-parse --short HEAD)" \
    -f web/admin-panel/Dockerfile \
    ./web/admin-panel
log "Web admin image built."

info "Pushing web admin image..."
docker push "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO/web-admin:latest"
docker push "$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO/web-admin:$(git rev-parse --short HEAD)"
log "Web admin image pushed."

# -----------------------------------------
# Update ECS services
# -----------------------------------------
info "Updating ECS services..."

aws ecs update-service \
    --cluster "$ECS_CLUSTER" \
    --service "$ECS_SERVICE_BACKEND" \
    --force-new-deployment \
    --region "$AWS_REGION" > /dev/null

aws ecs update-service \
    --cluster "$ECS_CLUSTER" \
    --service "$ECS_SERVICE_WEB" \
    --force-new-deployment \
    --region "$AWS_REGION" > /dev/null

log "ECS services updated."

# -----------------------------------------
# Run database migrations
# -----------------------------------------
info "Running database migrations..."
aws ecs run-task \
    --cluster "$ECS_CLUSTER" \
    --task-definition delivery-migration \
    --overrides '{"containerOverrides": [{"name": "migration", "command": ["npm", "run", "migration:run"]}]}' \
    --region "$AWS_REGION" > /dev/null
log "Migrations triggered."

# -----------------------------------------
# Success
# -----------------------------------------
COMMIT_SHA=$(git rev-parse --short HEAD)
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════╗"
echo "║        Deployment Complete!                   ║"
echo "╚═══════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "  Version:    $COMMIT_SHA"
echo "  Backend:    https://api.delivery.local"
echo "  Admin:      https://admin.delivery.local"
echo "  Region:     $AWS_REGION"
echo "  Cluster:    $ECS_CLUSTER"
echo ""
echo "  Monitor deployment:"
echo "    aws ecs describe-services --cluster $ECS_CLUSTER --services $ECS_SERVICE_BACKEND"
echo ""
