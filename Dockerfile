# Use official Node.js LTS image
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy only necessary application code (safe recursive copy)
COPY config ./config
COPY controllers ./controllers
COPY models ./models
COPY public ./public
COPY routes ./routes
COPY utils ./utils
COPY server.js ./
# (Add other specific entry points if any)

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose app port
EXPOSE 3000

# Define default command
CMD ["node", "server.js"]
