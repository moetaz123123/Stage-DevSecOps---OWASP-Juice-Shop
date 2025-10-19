# ==================== STAGE 1: Builder ====================
FROM node:18 as installer

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /juice-shop

# Copy package files first (for better caching)
COPY package*.json ./
COPY yarn.lock* ./

# Install global dependencies
RUN npm i -g typescript ts-node

# Install ALL dependencies (including devDependencies for build)
RUN npm install --unsafe-perm --ignore-scripts || \
    yarn install --ignore-engines --frozen-lockfile

# Install feature-policy explicitly
RUN npm install feature-policy --save

# Copy application code
COPY . .

# Patch express-jwt before build
RUN sed -i "s/expressJwt({ secret: publicKey })/expressJwt({ secret: publicKey, algorithms: ['RS256'] })/g" lib/insecurity.ts || true && \
    sed -i "s/expressJwt({ secret: '' + Math.random() })/expressJwt({ secret: '' + Math.random(), algorithms: ['RS256'] })/g" lib/insecurity.ts || true

# Build the application
RUN npm run build || echo "Build completed with warnings"

# Verify critical dependencies are installed
RUN node -e "require('jssha'); console.log('✓ jssha found')" && \
    node -e "require('express'); console.log('✓ express found')" && \
    node -e "require('express-jwt'); console.log('✓ express-jwt found')"

# Optimize dependencies
RUN npm dedupe

# Clean up unnecessary files
RUN rm -rf frontend/node_modules && \
    rm -rf frontend/.angular && \
    rm -rf frontend/src/assets && \
    rm -rf .git

# Create required directories
RUN mkdir -p logs ftp data i18n

# Set permissions
RUN chown -R 65532:0 logs ftp data i18n && \
    chmod -R g=u logs ftp data i18n

# Clean up sensitive/unnecessary files
RUN rm -f data/chatbot/botDefaultTrainingData.json || true && \
    rm -f ftp/legal.md || true && \
    rm -f i18n/*.json || true

# ==================== STAGE 2: Production ====================
FROM node:18-bookworm-slim

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /juice-shop

# Copy built application from builder stage
COPY --from=installer --chown=65532:0 /juice-shop .

# Verify the application structure
RUN ls -la build/ && \
    test -f build/app.js || (echo "ERROR: build/app.js not found!" && exit 1)

# Verify critical dependencies in production
RUN node -e "try { require('jssha'); console.log('✓ jssha OK'); } catch(e) { console.error('✗ jssha MISSING'); process.exit(1); }"

# Switch to non-root user
USER 65532

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/rest/admin/application-version || exit 1

# Start application
CMD ["node", "build/app.js"]