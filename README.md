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
- `.dockerignore` - Optimized build context exclusions