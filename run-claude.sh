#!/bin/bash

# Script to run Claude in a sandboxed Docker container with git workspace persistence

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐳 Claude Sandbox Container${NC}"
echo "Starting Claude in a sandboxed Docker environment..."

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Get current git user info for container (use actual host credentials)
if ! git config user.name > /dev/null 2>&1; then
    echo -e "${RED}❌ No git user.name configured. Please run: git config --global user.name 'Your Name'${NC}"
    exit 1
fi

if ! git config user.email > /dev/null 2>&1; then
    echo -e "${RED}❌ No git user.email configured. Please run: git config --global user.email 'your@email.com'${NC}"
    exit 1
fi

export GIT_AUTHOR_NAME="$(git config user.name)"
export GIT_AUTHOR_EMAIL="$(git config user.email)"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

echo -e "${YELLOW}📝 Git identity: $GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>${NC}"

# Check for SSH keys if they exist
if [[ -f ~/.ssh/id_rsa ]] || [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_ecdsa ]]; then
    echo -e "${YELLOW}🔑 SSH keys will be mounted for git authentication${NC}"
fi

# Build the container if it doesn't exist or if --build is passed
if [[ "$1" == "--build" ]] || ! docker image inspect claude-sandbox > /dev/null 2>&1; then
    echo -e "${YELLOW}🔨 Building Claude sandbox container...${NC}"
    docker-compose build
fi

# Run the container
echo -e "${GREEN}🚀 Starting Claude sandbox...${NC}"
echo -e "${YELLOW}💡 Tips:${NC}"
echo "  - Your git workspace is mounted and persistent"
echo "  - Git commits will be reflected on your host machine"
echo "  - Type 'exit' to leave the container"
echo ""

# Check if network access is needed (for Claude API calls)
if [[ "$1" == "--network" ]]; then
    echo -e "${YELLOW}🌐 Starting with network access enabled${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.override.yml run --rm claude-sandbox bash
else
    echo -e "${YELLOW}🔒 Starting in network-isolated mode (use --network flag to enable network)${NC}"
    # Start the container interactively
    docker-compose run --rm claude-sandbox bash
fi

echo -e "${GREEN}✅ Claude sandbox session ended${NC}"