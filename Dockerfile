FROM node:18-alpine

# Install bash for better compatibility
RUN apk add --no-cache bash

# Install Claude CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Fix shebang compatibility issue with BusyBox
RUN sed -i '1s|#!/usr/bin/env -S node --no-warnings --enable-source-maps|#!/usr/local/bin/node|' /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js

# Set working directory
WORKDIR /app

# Copy the codebase snapshot into the container
COPY . .

# Default command to run Claude CLI
CMD ["claude"]