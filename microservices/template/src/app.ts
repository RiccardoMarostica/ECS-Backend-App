import express, { Express } from 'express';
import cors from 'cors';
import { loggerMiddleware } from './middleware/logger.middleware';
import { errorMiddleware } from './middleware/error.middleware';
import { router } from './routes';

export const app: Express = express();

// Middleware
app.use(express.json());
app.use(cors());
app.use(loggerMiddleware);

// Routes
app.use('/', router);

// Error handling middleware (must be registered last)
app.use(errorMiddleware)
