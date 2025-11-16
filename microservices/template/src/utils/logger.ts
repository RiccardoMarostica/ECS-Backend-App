import { config } from '../config';

export interface Logger {
  debug(message: string, meta?: object): void;
  info(message: string, meta?: object): void;
  warn(message: string, meta?: object): void;
  error(message: string, meta?: object): void;
}

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

const LOG_LEVELS: Record<LogLevel, number> = {
  debug: 0,
  info: 1,
  warn: 2,
  error: 3,
};

class LoggerImpl implements Logger {
  private currentLevel: number;

  constructor(logLevel: string) {
    this.currentLevel = LOG_LEVELS[logLevel as LogLevel] ?? LOG_LEVELS.info;
  }

  private log(level: LogLevel, message: string, meta?: object): void {
    if (LOG_LEVELS[level] >= this.currentLevel) {
      const logEntry = {
        timestamp: new Date().toISOString(),
        level,
        message,
        ...meta,
      };
      console.log(JSON.stringify(logEntry));
    }
  }

  debug(message: string, meta?: object): void {
    this.log('debug', message, meta);
  }

  info(message: string, meta?: object): void {
    this.log('info', message, meta);
  }

  warn(message: string, meta?: object): void {
    this.log('warn', message, meta);
  }

  error(message: string, meta?: object): void {
    this.log('error', message, meta);
  }
}

export const logger: Logger = new LoggerImpl(config.logLevel);
