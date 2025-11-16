import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export const loggerMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = Date.now();

  // Log request start
  logger.info('HTTP Request', {
    method: req.method,
    path: req.path,
    timestamp: new Date().toISOString(),
  });

  // Capture the original end function
  const originalEnd = res.end;

  // Override res.end to log after response is sent
  res.end = function (chunk?: any, encoding?: any, callback?: any): Response {
    // Calculate duration
    const duration = Date.now() - startTime;

    // Log response completion
    logger.info('HTTP Response', {
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration,
    });

    // Call the original end function with proper arguments
    return originalEnd.call(this, chunk, encoding, callback) as Response;
  };

  next();
};
