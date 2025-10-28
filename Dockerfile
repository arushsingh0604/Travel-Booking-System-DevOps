# Use a Node.js base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package files for both frontend and backend
# Copy backend first
COPY backend/package*.json ./backend/
# Copy frontend (assuming it's in a subdirectory)
COPY frontend/package*.json ./frontend/

# Install backend dependencies
WORKDIR /app/backend
RUN npm install

# Install frontend dependencies
WORKDIR /app/frontend
RUN npm install

# Go back to the main app directory
WORKDIR /app

# Copy the rest of the backend code
COPY backend/ .

# Copy the rest of the frontend code
COPY frontend/ ./frontend/

# Build the frontend (if necessary)
WORKDIR /app/frontend
RUN npm run build
# Copy the built frontend assets to the backend's public directory
# Adjust paths as needed for your project structure
RUN cp -r build/* ../public/

# Go back to the main app directory (where server.js likely is)
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership (adjust path if server.js is not in /app)
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser

# Expose the port the backend runs on
EXPOSE 8080

# Command to run the backend server
CMD ["node", "server.js"]
