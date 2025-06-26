#!/bin/bash

# Publish script for Claude in a Box Docker image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

IMAGE_NAME="roasbeef/claude-in-a-box"
TAG="${1:-latest}"

echo -e "${BLUE}📦 Publishing Claude in a Box Docker image${NC}"
echo -e "${YELLOW}Image: $IMAGE_NAME:$TAG${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Build the image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
docker build -t "$IMAGE_NAME:$TAG" .

# Tag as latest if not already latest
if [[ "$TAG" != "latest" ]]; then
    docker tag "$IMAGE_NAME:$TAG" "$IMAGE_NAME:latest"
fi

# Push to Docker Hub
echo -e "${YELLOW}⬆️  Pushing to Docker Hub...${NC}"
docker push "$IMAGE_NAME:$TAG"

if [[ "$TAG" != "latest" ]]; then
    docker push "$IMAGE_NAME:latest"
fi

echo ""
echo -e "${GREEN}✅ Successfully published $IMAGE_NAME:$TAG${NC}"
echo ""
echo -e "${BLUE}One-line install command:${NC}"
echo "curl -fsSL https://raw.githubusercontent.com/roasbeef/claude-in-a-box/main/install.sh | bash"