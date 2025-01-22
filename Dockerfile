# Build Backend
FROM node:21.6-alpine3.18 AS backend-builder

WORKDIR /app/backend

# Install backend dependencies
COPY backend/package.json backend/package-lock.json ./
RUN npm ci

# Copy backend source code and transpile
COPY backend ./
RUN npx tsc

# Build Frontend
FROM node:21.6-alpine3.18 AS frontend-builder

WORKDIR /app/ui

# Install frontend dependencies
COPY ui/package.json ui/package-lock.json ./
RUN npm ci

# Build frontend
COPY ui ./
RUN npm run build

# Final Image
FROM alpine:3.18

# Metadata for Docker Desktop
LABEL org.opencontainers.image.title="DockIQ" \
    org.opencontainers.image.description="Docker Monitoring Health Tool" \
    org.opencontainers.image.vendor="TheChefs" \
    com.docker.desktop.extension.api.version="0.3.4"

# Install Node.js runtime
RUN apk add --no-cache nodejs npm

# Copy built backend and frontend files
COPY --from=backend-builder /app/backend/dist /app/backend
COPY --from=frontend-builder /app/ui/build /ui

# Copy required files for Docker Desktop
COPY metadata.json .
COPY docker-compose.yaml .
COPY docker.svg .
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Expose backend port
EXPOSE 3000

# Run the backend service
CMD ["node", "/app/backend/app.js"]
