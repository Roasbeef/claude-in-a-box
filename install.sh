#!/bin/bash

# Claude in a Box - One-line installer
# Installs the claude-box function for running Claude CLI from any git repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Claude in a Box - One-line installer${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Validate git config
if ! git config user.name > /dev/null 2>&1; then
    echo -e "${RED}❌ No git user.name configured. Please run: git config --global user.name 'Your Name'${NC}"
    exit 1
fi

if ! git config user.email > /dev/null 2>&1; then
    echo -e "${RED}❌ No git user.email configured. Please run: git config --global user.email 'your@email.com'${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Try to pull the Docker image
echo -e "${YELLOW}📦 Pulling Docker image...${NC}"
if docker pull roasbeef/claude-in-a-box:latest > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker image pulled successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Pre-built image not found. Building locally...${NC}"
    # Clone and build if image doesn't exist
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    cd "$TEMP_DIR"
    git clone https://github.com/roasbeef/claude-in-a-box.git
    cd claude-in-a-box
    docker build -t roasbeef/claude-in-a-box:latest .
    echo -e "${GREEN}✅ Docker image built successfully${NC}"
fi

# Detect shell and config file
SHELL_CONFIG=""
if [[ "$SHELL" == *"zsh"* ]] && [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]] && [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_CONFIG="$HOME/.bash_profile"
elif [[ -f "$HOME/.profile" ]]; then
    SHELL_CONFIG="$HOME/.profile"
else
    # Create .bashrc if nothing exists
    SHELL_CONFIG="$HOME/.bashrc"
    touch "$SHELL_CONFIG"
fi

echo -e "${YELLOW}📝 Installing claude-box function to $SHELL_CONFIG${NC}"

# Check if function already exists
if grep -q "claude-box()" "$SHELL_CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  claude-box function already exists. Updating...${NC}"
    # Remove existing function
    sed -i.bak '/^claude-box()/,/^}$/d' "$SHELL_CONFIG"
fi

# Add the function
cat >> "$SHELL_CONFIG" << 'EOF'

# Claude in a Box function
claude-box() {
    # Validate git config
    if ! git config user.name > /dev/null 2>&1; then
        echo "❌ No git user.name configured. Please run: git config --global user.name 'Your Name'"
        return 1
    fi
    
    if ! git config user.email > /dev/null 2>&1; then
        echo "❌ No git user.email configured. Please run: git config --global user.email 'your@email.com'"
        return 1
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker first."
        return 1
    fi
    
    # Set git environment variables
    export GIT_AUTHOR_NAME="$(git config user.name)"
    export GIT_AUTHOR_EMAIL="$(git config user.email)"
    export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL"
    
    # Run Claude container with full security hardening
    docker run --rm -it \
        -v "$(pwd)":/workspace \
        -v ~/.gitconfig:/home/claude/.gitconfig:ro \
        -v ~/.ssh:/home/claude/.ssh:ro \
        -w /workspace \
        -e GIT_AUTHOR_NAME \
        -e GIT_AUTHOR_EMAIL \
        -e GIT_COMMITTER_NAME \
        -e GIT_COMMITTER_EMAIL \
        --security-opt no-new-privileges:true \
        --cap-drop ALL \
        --cap-add DAC_OVERRIDE \
        --network none \
        --tmpfs /tmp:noexec,nosuid,nodev,size=100m \
        --tmpfs /var/tmp:noexec,nosuid,nodev,size=50m \
        --memory=1g \
        --memory-swap=1g \
        --cpu-quota=100000 \
        --pids-limit=100 \
        roasbeef/claude-in-a-box:latest bash
}
EOF

echo -e "${GREEN}✅ claude-box function installed successfully${NC}"

# Try to reload the shell config
if [[ "$SHELL_CONFIG" == *".zshrc"* ]]; then
    echo -e "${YELLOW}📝 Reloading zsh configuration...${NC}"
    exec zsh -l
elif [[ "$SHELL_CONFIG" == *".bashrc"* ]] || [[ "$SHELL_CONFIG" == *".bash_profile"* ]]; then
    echo -e "${YELLOW}📝 Reloading bash configuration...${NC}"
    source "$SHELL_CONFIG"
fi

echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  1. Navigate to any git repository"
echo "  2. Run: claude-box"
echo "  3. Claude will start with access to your current directory"
echo ""
echo -e "${YELLOW}💡 Tip: You may need to restart your terminal or run 'source $SHELL_CONFIG'${NC}"