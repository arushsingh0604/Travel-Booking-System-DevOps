# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Build step (if applicable — for React or other frontend assets)
# Uncomment the next line if your project has a build script
# RUN npm run build

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app
USER appuser

# Expose the port (check your app.js/server.js for actual port)
EXPOSE 8080

# Run the app
CMD ["npm", "start"]
