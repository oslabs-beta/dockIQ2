# ----------------------------------------
# 1) Builder Stage (Build TypeScript)
# ----------------------------------------
  FROM --platform=$BUILDPLATFORM node:18.9-alpine3.15 AS backend_builder

  WORKDIR /app/backend
  
  # Copy package files first to leverage Docker's cache
  COPY package.json package-lock.json ./
  
  # Install dependencies including dev dependencies
  RUN npm ci --include=dev
  
  # Copy the rest of the backend source code
  COPY . .
  
  # Build the production backend
  RUN npm run build
  
  # ----------------------------------------
  # 2) Development Stage (Live Reloading)
  # ----------------------------------------
  FROM node:18.9-alpine3.15 AS backend_dev
  
  WORKDIR /app/backend
  
  # Copy package files
  COPY package.json package-lock.json ./
  
  # Install dependencies for development
  RUN npm ci --include=dev
  
  # Copy the source code
  COPY . .
  
  # Install nodemon globally for live reloading
  RUN npm install -g nodemon
  
  # Expose backend dev server port
  EXPOSE 3000
  
  # Start the backend in development mode
  CMD ["nodemon", "--watch", "src", "--exec", "node", "src/app.js"]
  
  # ----------------------------------------
  # 3) Production Stage
  # ----------------------------------------
  FROM node:18-alpine AS backend_prod
  
  WORKDIR /app/backend
  
  # Copy built files, node_modules, and package.json from the builder stage
  COPY --from=backend_builder /app/backend/dist /app/backend/dist
  COPY --from=backend_builder /app/backend/node_modules /app/backend/node_modules
  COPY --from=backend_builder /app/backend/package.json /app/backend/package.json
  
  # Expose backend production server port
  EXPOSE 3000
  
  # Start the backend in production mode
  CMD ["node", "/app/backend/dist/app.js"]
  