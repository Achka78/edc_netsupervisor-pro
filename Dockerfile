# Multi-stage build for production optimization

# Stage 1: Build React Client
FROM node:18-alpine AS client-builder

WORKDIR /app/client

# Copy client package files
COPY client/package*.json ./
RUN npm ci --only=production

# Copy client source and build
COPY client/ ./
RUN npm run build

# Stage 2: Build Server Dependencies
FROM node:18-alpine AS server-deps

WORKDIR /app

# Install system dependencies for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat \
    openssl-dev

# Copy server package files
COPY package*.json ./
COPY server/package*.json ./server/

# Install server dependencies
RUN npm ci --only=production

# Stage 3: Production Image
FROM node:18-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl \
    netcat-openbsd \
    iputils \
    net-snmp-tools \
    openssh-client

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy built client from stage 1
COPY --from=client-builder --chown=nodejs:nodejs /app/client/build ./client/build

# Copy server dependencies from stage 2
COPY --from=server-deps --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=server-deps --chown=nodejs:nodejs /app/server/node_modules ./server/node_modules

# Copy server source
COPY --chown=nodejs:nodejs server/ ./server/
COPY --chown=nodejs:nodejs package*.json ./

# Create necessary directories
RUN mkdir -p logs uploads backups && \
    chown -R nodejs:nodejs logs uploads backups

# Switch to non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-5000}/api/health || exit 1

# Expose port
EXPOSE 5000

# Start application with dumb-init
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server/server.js"]

# Development Stage
FROM node:18-alpine AS development

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat \
    openssl-dev \
    curl \
    netcat-openbsd \
    iputils \
    net-snmp-tools \
    openssh-client

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY server/package*.json ./server/
COPY client/package*.json ./client/

# Install all dependencies (including dev)
RUN npm install
RUN cd server && npm install
RUN cd client && npm install

# Copy source code
COPY . .

# Create directories
RUN mkdir -p logs uploads backups

# Expose ports (server and client)
EXPOSE 5000 3000

# Development command
CMD ["npm", "run", "dev"]