# ----------------------------------------
# 1) Builder Stage (Build TypeScript)
# ----------------------------------------
  FROM --platform=$BUILDPLATFORM node:18.9-alpine3.15 AS backend_builder

  WORKDIR /app/backend
  
  # Step 1: Copy package files (only these first to improve build cache efficiency)
  COPY package.json package-lock.json ./
  
  # Step 2: Install all dependencies including dev dependencies
  RUN --mount=type=cache,target=/usr/src/app/.npm \
      npm set cache /usr/src/app/.npm && \
      npm ci --include=dev
  
  # Step 3: Copy the rest of the backend source code
  COPY . .
  
  # Step 4: Run the build script (TypeScript to JavaScript)
  RUN npm run build
  
  # ----------------------------------------
  # 2) Development Stage (Live Reloading)
  # ----------------------------------------
  FROM node:18.9-alpine3.15 AS backend_dev
  
  WORKDIR /app/backend
  
  # Copy package files for development environment
  COPY package.json package-lock.json ./
  
  # Install dependencies (including dev dependencies for `nodemon`)
  RUN npm ci --include=dev
  
  # Copy the source code for live reloading (no need to copy ui)
  COPY . .
  
  # Install `nodemon` globally for live reloading
  RUN npm install -g nodemon
  
  EXPOSE 3000
  
  # Run the backend in development mode with live reloading
  CMD ["nodemon", "--watch", "src", "--exec", "node", "src/app.js"]
  
  # ----------------------------------------
  # 3) Production Stage
  # ----------------------------------------
  FROM alpine:3.15 AS backend_prod
  
  # Install Node.js and npm
  RUN apk add --no-cache nodejs npm
  
  WORKDIR /app/backend
  
  # Copy built files, dependencies, and package.json from the builder stage
  COPY --from=backend_builder /app/backend/dist /app/backend/dist
  COPY --from=backend_builder /app/backend/node_modules /app/backend/node_modules
  COPY --from=backend_builder /app/backend/package.json /app/backend/package.json
  
  EXPOSE 3000
  
  # Start the backend in production mode
  CMD ["npm", "--prefix", "/app/backend", "start"]
  