# Claude in a Box

A secure, containerized environment for running Claude Code CLI with git workspace persistence and your actual credentials.

## Features

- 🐳 **Containerized Security**: Claude runs in an isolated Docker environment with security hardening
- 🔄 **Git Workspace Persistence**: Changes made by Claude are reflected in your local git repository
- 🔑 **Credential Integration**: Uses your actual git credentials and SSH keys for authentic commits
- 🛡️ **Security Hardening**: Non-root user, dropped capabilities, and read-only security features
- 📦 **Easy Setup**: Simple script-based deployment with docker-compose

## Quick Start

1. **Run the setup script**:
   ```bash
   ./run-claude.sh
   ```

2. **Or build and run manually**:
   ```bash
   docker-compose build
   docker-compose run --rm claude-sandbox bash
   ```

## How it Works

The system creates a secure Docker container that:

- Mounts your git workspace as a volume for persistent changes
- Inherits your git configuration (`~/.gitconfig`) and SSH keys
- Runs Claude CLI as a non-root user with minimal privileges
- Enables Claude to make commits that appear in your local git history

## One-Line Setup (Easiest)

Install and run from any git repository with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/roasbeef/claude-in-a-box/main/install.sh | bash
```

This will:
1. Pull the pre-built Docker image
2. Install the `claude-box` function in your shell
3. Let you run `claude-box` from any git repository

## Global Usage (Manual Setup)

For easier access from any git repository, add this function to your `~/.bashrc` or `~/.zshrc`:

```bash
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
        --tmpfs /tmp:noexec,nosuid,nodev,size=100m \
        --tmpfs /var/tmp:noexec,nosuid,nodev,size=50m \
        --memory=1g \
        --memory-swap=1g \
        --cpu-quota=100000 \
        --pids-limit=100 \
        roasbeef/claude-in-a-box claude
}
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

Now you can run `claude-box` from any git repository!

## Configuration

### Git Integration
- Your `~/.gitconfig` is mounted read-only
- Git commits use your actual name and email
- SSH keys are mounted for authenticated git operations
- All git operations persist to your host machine

### Security Features
- Non-root user execution (UID 1001)
- Dropped Linux capabilities (keeps only DAC_OVERRIDE)
- No new privileges flag
- Temporary filesystem with security restrictions

## Files

- `Dockerfile` - Container definition with Claude CLI and security hardening
- `docker-compose.yml` - Service configuration with volume mounts and security settings
- `run-claude.sh` - Convenience script for container management
- `install.sh` - One-line installer for global setup
- `publish.sh` - Script to build and publish Docker image to Docker Hub
- `.dockerignore` - Optimized build context exclusions