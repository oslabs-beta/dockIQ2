# Base image for Node.js
FROM node:18 AS base
WORKDIR /app

# Copy shared files
COPY package*.json ./
RUN npm install

# Development stage
FROM base AS dev
ENV NODE_ENV=development
WORKDIR /app
# Mount source code in dev mode
CMD ["npm", "run", "dev"]

# Production stage for Backend
FROM base AS backend
ENV NODE_ENV=production
WORKDIR /app/backend
COPY backend ./
RUN npm run build # Build TypeScript to JavaScript
CMD ["node", "dist/index.js"]

# Production stage for Frontend
FROM base AS frontend
ENV NODE_ENV=production
WORKDIR /app/ui
COPY ui ./
RUN npm run build # Build static files
CMD ["npm", "run", "start"]

# Prometheus base image
FROM prom/prometheus:latest AS prometheus

# Final image for the Docker Desktop extension
FROM alpine:3.15 AS final

# Copy built frontend files
COPY --from=frontend /app/ui/build /ui

# Copy built backend files
COPY --from=backend /app/backend/dist /app/backend

# Copy Prometheus configuration file
COPY --from=prometheus /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml

# Copy extension metadata and other assets
COPY metadata.json . 
COPY docker-compose.yaml . 
COPY docker.svg .

# Set extension labels
LABEL org.opencontainers.image.title="DockIQ Extension" \
      org.opencontainers.image.description="Docker monitoring health extension" \
      com.docker.desktop.extension.api.version="0.3.4"

# Command to keep container alive (for UI-based extensions)
CMD ["sleep", "infinity"]
