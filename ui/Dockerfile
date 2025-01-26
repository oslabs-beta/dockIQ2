# ----------------------------------------
# 1) Builder Stage (Build TypeScript)
# ----------------------------------------
    FROM --platform=$BUILDPLATFORM node:18.9-alpine3.15 AS ui-builder

    WORKDIR /app/ui
    
    # Copy only package files to leverage Docker's build cache
    COPY ./ui/package.json ./ui/package-lock.json ./
    
    # Install production dependencies
    RUN npm ci
    
    # Copy the entire frontend source code
    COPY ./ui ./
    
    # Build the production app (Vite build)
    RUN npm run build
    
    # ----------------------------------------
    # 2) Development Stage (Live Reloading)
    # ----------------------------------------
    FROM node:18.9-alpine3.15 AS ui-dev
    
    WORKDIR /app/ui
    
    # Copy package.json and install dev dependencies
    COPY ./ui/package.json ./ui/package-lock.json ./
    RUN npm ci
    
    # Copy the source code
    COPY ./ui ./
    
    # Debugging: Verify node_modules and Vite installation
    RUN ls -al /app/ui/node_modules/.bin
    
    # Expose dev server port
    EXPOSE 3044
    
    # Start the Vite development server
    CMD ["npm", "run", "dev"]
    
    # ----------------------------------------
    # 3) Production Stage
    # ----------------------------------------
    FROM nginx:alpine AS ui-prod
    
    # Copy the production build from the ui-builder stage
    COPY --from=ui-builder /app/ui/build /usr/share/nginx/html
    
    # Expose the production server port
    EXPOSE 3000
    
    # Start the production server
    CMD ["nginx", "-g", "daemon off;"]
    