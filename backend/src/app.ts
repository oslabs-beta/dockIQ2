import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors'; // Import CORS package
import metricsRouter from './routes/metrics';
import containerStatsRouter from './routes/containerStats'; // Import the new container-stats route

const app: Application = express();

// Add CORS middleware using the `cors` package
app.use(
  cors({
    origin: ['http://localhost:3044', 'http://localhost:3000'], // Allow both frontend dev server and mapped container
    methods: ['GET', 'POST', 'PUT', 'DELETE'], // Define allowed HTTP methods
    allowedHeaders: ['Content-Type', 'Authorization'], // Define allowed headers
    credentials: true, // Allow cookies or credentials if needed
  })
);
// Add request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log('Headers:', req.headers);
  console.log('Query:', req.query);
  console.log('Body:', req.body);
  next();
});

// Middleware to parse JSON requests
app.use(express.json());

// Basic health check route
app.get('/', (req: Request, res: Response) => {
  console.log('Root route hit');
  res.json({ status: 'ok', message: 'Backend server is running!' });
});

// Ping route
app.get('/ping', (req: Request, res: Response) => {
  console.log('Ping route hit');
  res.json({ status: 'ok', message: 'pong' });
});

// Metrics routes
app.use('/metrics', metricsRouter);

// Container Stats route
app.use('/api', containerStatsRouter); // Register the container-stats route under "/api"

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({ status: 'error', message: err.message });
});

// Define the port from the environment or default to 3000
const internalPort = Number(process.env.PORT) || 3000;
const hostPort = Number(process.env.HOST_PORT) || internalPort;

// Start the server
app.listen(internalPort, '0.0.0.0', () => {
  console.log(`Backend server running on internal port ${internalPort}`);
  console.log(`Try accessing: http://localhost:${hostPort}/ping`);
});

export default app;
