# ---- FRONTEND BUILD STAGE ----
FROM node:18-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# ---- BACKEND RUNTIME STAGE ----
FROM node:18-alpine

WORKDIR /app

# Copy dependencies first for better caching
COPY backend/package*.json ./
RUN npm install

# Copy backend source code
COPY backend/ .

# Copy built frontend assets from the frontend stage
COPY --from=frontend /app/frontend/build ./public

# Create a non-root user and group
# '-S' creates a system user/group (specific to Alpine)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership of the app directory to the new user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8080

# Command to run the application
CMD ["node", "server.js"]
