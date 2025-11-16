import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { ErrorResponse } from '../types';

export const errorMiddleware = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  // Log error details with stack trace
  logger.error('Unhandled error', {
    error: err.name,
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  // Determine status code
  const statusCode = (err as any).statusCode || 500;

  // Build error response
  const errorResponse: ErrorResponse = {
    error: err.name || 'InternalServerError',
    message: err.message || 'An unexpected error occurred',
    statusCode,
    path: req.path,
    timestamp: new Date().toISOString(),
  };

  // Send error response
  res.status(statusCode).json(errorResponse);
};
