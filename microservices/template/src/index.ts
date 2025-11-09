import { Server } from 'http';
import { app } from './app';
import { config } from './config';
import { logger } from './utils/logger';

let server: Server;

function startServer(): void {
  server = app.listen(config.port, () => {
    logger.info('Server started', {
      service: config.serviceName,
      port: config.port,
      nodeEnv: config.nodeEnv,
    });
  });
}

function gracefulShutdown(signal: string): void {
  logger.info('Shutdown signal received', { signal });
  
  if (server) {
    server.close(() => {
      logger.info('Server closed');
      process.exit(0);
    });

    // Force shutdown after 10 seconds
    setTimeout(() => {
      logger.error('Forced shutdown after timeout');
      process.exit(1);
    }, 10000);
  } else {
    process.exit(0);
  }
}

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start the server
startServer();
