import { Request, Response } from 'express';
import { HealthResponse } from '../types';
import { config } from '../config';

export const getHealth = (_req: Request, res: Response): void => {
  const healthResponse: HealthResponse = {
    status: 'healthy',
    service: config.serviceName,
    version: '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  };

  res.status(200).json(healthResponse);
};
