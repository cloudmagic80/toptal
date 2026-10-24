# api/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files and install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application source code
COPY . .

# Run as non-root user for security
USER node

# Cloud Run defaults to port 8080
EXPOSE 8080

CMD ["npm", "start"]