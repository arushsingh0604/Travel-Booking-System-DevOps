# Use a specific Node.js LTS version for stability and security
FROM node:18.20.3-alpine AS base

# Set working directory
WORKDIR /app

# Copy only package files first (improves layer caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy source code safely
# It's better to explicitly include only required directories
# and use a .dockerignore file to exclude secrets, node_modules, etc.
COPY src ./src
COPY public ./public
COPY server.js ./

# (Optional) Uncomment if you have a frontend build step
# RUN npm run build

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 8080

# Use a non-root entrypoint
CMD ["node", "server.js"]
