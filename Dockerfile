# Multi-stage build for Absendo frontend
# Stage 1: Build
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production
FROM node:18-alpine as production

WORKDIR /app

# Install serve to run the static build
RUN npm install -g serve

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Create a simple server script
RUN echo '#!/bin/sh\nserve -s dist -l 3000' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

ENTRYPOINT ["/entrypoint.sh"]
