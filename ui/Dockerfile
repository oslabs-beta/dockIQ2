# ----------------------------------------
# 1) Builder Stage (Build TypeScript)
# ----------------------------------------
    FROM --platform=$BUILDPLATFORM node:18.9-alpine3.15 AS ui-builder

    WORKDIR /app/ui
    
    # Copy only package.json and package-lock.json to leverage cache
    COPY ./ui/package.json ./ui/package-lock.json ./
    
    # Install dependencies (npm ci will install only the production dependencies)
    RUN npm ci
    
    # Copy the rest of the source code
    COPY ./ui ./
    
    # Build the production app (Vite build)
    RUN npm run build
    
    # ----------------------------------------
    # 2) Development Stage (Live Reloading)
    # ----------------------------------------
    FROM node:18.9-alpine3.15 AS ui-dev
    
    WORKDIR /app/ui
    
    # Copy only package.json and package-lock.json
    COPY ./ui/package.json ./ui/package-lock.json ./
    
    # Install dependencies (including dev dependencies like Vite)
    RUN npm ci
    
    # Copy the source code
    COPY ./ui ./
    
    # Debugging: Verify node_modules and Vite installation
    RUN ls -al /app/ui/node_modules/.bin
    
    # Start the Vite development server
    CMD ["npm", "run", "dev"]
    
    # ----------------------------------------
    # 3) Production Stage
    # ----------------------------------------
    FROM alpine:3.15 AS ui-prod
    
    # Install Node.js and npm for running the production build
    RUN apk add --no-cache nodejs npm
    
    # Copy the production build from the ui-builder stage
    COPY --from=ui-builder /app/ui/build /app/ui/build
    
    # Install `serve` for serving static files
    RUN npm install -g serve
    
    # Expose the port for the production server
    EXPOSE 3000
    
    # Start the production server
    CMD ["serve", "-s", "/app/ui/build"]
    