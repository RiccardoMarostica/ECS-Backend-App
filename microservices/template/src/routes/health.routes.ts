import { Router } from 'express';
import { getHealth } from '../controllers/health.controller';
import { config } from '../config';

export const healthRouter = Router();

healthRouter.get('/health', getHealth);

healthRouter.get('/', (_req, res) => {
  res.status(200).json({
    service: config.serviceName,
    version: '1.0.0',
    description: 'Production-ready TypeScript microservice template for AWS ECS deployment',
  });
});
