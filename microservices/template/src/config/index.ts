import dotenv from 'dotenv';

// Load environment variables from .env file
dotenv.config();

export interface Config {
  port: number;
  nodeEnv: string;
  serviceName: string;
  logLevel: string;
}

function validateConfig(): Config {
  const port = parseInt(process.env.PORT || '8080', 10);
  const nodeEnv = process.env.NODE_ENV || 'development';
  const serviceName = process.env.SERVICE_NAME || 'template-service';
  const logLevel = process.env.LOG_LEVEL || 'info';

  // Validate port is a valid number
  if (isNaN(port) || port < 1 || port > 65535) {
    console.error('ERROR: PORT must be a valid number between 1 and 65535');
    process.exit(1);
  }

  // Validate log level
  const validLogLevels = ['debug', 'info', 'warn', 'error'];
  if (!validLogLevels.includes(logLevel)) {
    console.error(`ERROR: LOG_LEVEL must be one of: ${validLogLevels.join(', ')}`);
    process.exit(1);
  }

  return {
    port,
    nodeEnv,
    serviceName,
    logLevel,
  };
}

export const config: Config = validateConfig();
