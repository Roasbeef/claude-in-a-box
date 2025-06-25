# Claude in a Box

A containerized environment for running Claude Code CLI with isolated codebase snapshots.

## Usage

Build the container from your project directory:

```bash
docker build -t claude-container .
```

Run Claude CLI in an isolated environment:

```bash
docker run -it claude-container
```

Each container run creates a fresh snapshot of your codebase, allowing multiple Claude instances to operate independently without interfering with each other or your working directory.

## How it works

The Dockerfile installs the Claude CLI globally using npm and copies your entire codebase into the container. This creates an isolated environment where Claude can analyze and modify code without affecting your local files or other running instances.