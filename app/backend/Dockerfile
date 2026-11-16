FROM node:24-alpine AS builder
WORKDIR /app/backend

# Copy package files first to leverage Docker cacheing
COPY backend/package*.json ./
RUN npm ci --omit=dev

# Stage 2: Final Runtime Environment
FROM node:24-alpine
WORKDIR /app

COPY --chown=node:node --from=builder /app/backend/node_modules ./backend/node_modules
COPY --chown=node:node backend/ ./backend/
COPY --chown=node:node database/schema.sql ./database/schema.sql
COPY --chown=node:node frontend/ ./frontend/

# Expose the API Application port
EXPOSE 5000

# Set production execution flags
ENV NODE_ENV=production
USER node
WORKDIR /app/backend

# Execute the application entry point
CMD ["node", "server.js"]