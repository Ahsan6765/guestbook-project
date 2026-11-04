FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files first to leverage Docker cacheing
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Final Runtime Environment
FROM node:20-alpine
WORKDIR /app

# Create a non-privileged system user from the builder phase
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=user:node . .

# Expose the API Application port
EXPOSE 5000

# Set production execution flags
ENV NODE_ENV=production

# Execute the application entry point
CMD ["node", "server.js"]