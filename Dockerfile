# Use a specific Node.js LTS version for stability and security
FROM node:18.20.3-alpine AS base

# Set working directory
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy only required app files safely
# Adjust according to your repo contents
COPY . ./

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the backend port (adjust if your app runs on another)
EXPOSE 8080

# Command to run the application
CMD ["node", "server.js"]
