FROM node:18-alpine

# Install bash and git for better compatibility
RUN apk add --no-cache bash git

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Fix shebang compatibility issue with BusyBox
RUN sed -i '1s|#!/usr/bin/env -S node --no-warnings --enable-source-maps|#!/usr/local/bin/node|' /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js

# Create non-root user for security with home directory
# Use a higher UID to avoid conflicts with existing system groups
RUN addgroup -g 1001 claude && \
    adduser -u 1001 -G claude -s /bin/bash -D claude

# Set up git configuration for safety
RUN git config --system --add safe.directory '*'

# Set working directory
WORKDIR /workspace

# Copy the codebase snapshot into the container
COPY . .

# Set permissions
RUN chown -R claude:claude /workspace

# Switch to non-root user
USER claude

# Set up default git user identity (can be overridden by volume mount)
RUN git config --global user.name "Claude Container" && \
    git config --global user.email "claude@container.local"

# Default command to run Claude CLI
CMD ["claude"]