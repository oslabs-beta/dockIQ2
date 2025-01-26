import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    outDir: 'build', // Output directory for the production build
  },
  server: {
    host: '0.0.0.0', // Expose the server to external connections
    port: process.env.NODE_ENV === 'development' ? 3044 : 3000, // 3044 locally, 3000 in Docker
    strictPort: true, // Prevent Vite from switching ports
    watch: {
      usePolling: true, // Ensure file changes are detected in Docker
    },
  },
  define: {
    'process.env.VITE_API_URL': JSON.stringify(
      process.env.NODE_ENV === 'development'
        ? 'http://localhost:3015' // Local backend for local dev
        : 'http://backend:3000' // Docker backend for containerized environment
    ),
  },
});
