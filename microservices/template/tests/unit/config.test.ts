import { it } from "node:test";

import { afterEach, beforeEach, describe } from "node:test";

describe('Configuration Module', () => {
  const originalEnv = process.env;
  let consoleErrorSpy: jest.SpyInstance;
  let processExitSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...originalEnv };
    consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
    processExitSpy = jest.spyOn(process, 'exit').mockImplementation((() => {
      throw new Error('process.exit: 1');
    }) as any);
  });

  afterEach(() => {
    process.env = originalEnv;
    consoleErrorSpy.mockRestore();
    processExitSpy.mockRestore();
  });

  it('should load environment variables correctly', () => {
    process.env.PORT = '3000';
    process.env.NODE_ENV = 'production';
    process.env.SERVICE_NAME = 'test-service';
    process.env.LOG_LEVEL = 'debug';

    const { config } = require('../../src/config');

    expect(config.port).toBe(3000);
    expect(config.nodeEnv).toBe('production');
    expect(config.serviceName).toBe('test-service');
    expect(config.logLevel).toBe('debug');
  });

  it('should apply default values when environment variables are not set', () => {
    delete process.env.PORT;
    delete process.env.NODE_ENV;
    delete process.env.SERVICE_NAME;
    delete process.env.LOG_LEVEL;

    const { config } = require('../../src/config');

    expect(config.port).toBe(8080);
    expect(config.nodeEnv).toBe('development');
    expect(config.serviceName).toBe('template-service');
    expect(config.logLevel).toBe('info');
  });

  it('should apply default port when PORT is not set', () => {
    delete process.env.PORT;

    const { config } = require('../../src/config');

    expect(config.port).toBe(8080);
  });

  it('should apply default NODE_ENV when not set', () => {
    delete process.env.NODE_ENV;

    const { config } = require('../../src/config');

    expect(config.nodeEnv).toBe('development');
  });

  it('should apply default SERVICE_NAME when not set', () => {
    delete process.env.SERVICE_NAME;

    const { config } = require('../../src/config');

    expect(config.serviceName).toBe('template-service');
  });

  it('should apply default LOG_LEVEL when not set', () => {
    delete process.env.LOG_LEVEL;

    const { config } = require('../../src/config');

    expect(config.logLevel).toBe('info');
  });

  it('should fail validation for invalid port (non-numeric)', () => {
    process.env.PORT = 'invalid';

    expect(() => {
      require('../../src/config');
    }).toThrow('process.exit: 1');

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'ERROR: PORT must be a valid number between 1 and 65535'
    );
  });

  it('should fail validation for port below valid range', () => {
    process.env.PORT = '0';

    expect(() => {
      require('../../src/config');
    }).toThrow('process.exit: 1');

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'ERROR: PORT must be a valid number between 1 and 65535'
    );
  });

  it('should fail validation for port above valid range', () => {
    process.env.PORT = '65536';

    expect(() => {
      require('../../src/config');
    }).toThrow('process.exit: 1');

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'ERROR: PORT must be a valid number between 1 and 65535'
    );
  });

  it('should fail validation for invalid log level', () => {
    process.env.LOG_LEVEL = 'invalid';

    expect(() => {
      require('../../src/config');
    }).toThrow('process.exit: 1');

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'ERROR: LOG_LEVEL must be one of: debug, info, warn, error'
    );
  });

  it('should accept all valid log levels', () => {
    const validLevels = ['debug', 'info', 'warn', 'error'];

    validLevels.forEach((level) => {
      jest.resetModules();
      process.env.LOG_LEVEL = level;

      const { config } = require('../../src/config');
      expect(config.logLevel).toBe(level);
    });
  });
});
