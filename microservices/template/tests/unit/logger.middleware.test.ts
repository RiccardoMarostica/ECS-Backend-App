import { Request, Response, NextFunction } from 'express';
import { loggerMiddleware } from '../../src/middleware/logger.middleware';
import { logger } from '../../src/utils/logger';

jest.mock('../../src/utils/logger');

describe('Logger Middleware', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let mockNext: NextFunction;
  let mockLoggerInfo: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    
    mockRequest = {
      method: 'GET',
      path: '/test',
    };

    mockResponse = {
      end: jest.fn(),
      statusCode: 200,
    };

    mockNext = jest.fn();
    mockLoggerInfo = jest.fn();
    (logger.info as jest.Mock) = mockLoggerInfo;
  });

  it('should log request details on request start', () => {
    loggerMiddleware(
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(mockLoggerInfo).toHaveBeenCalledWith(
      'HTTP Request',
      expect.objectContaining({
        method: 'GET',
        path: '/test',
        timestamp: expect.any(String),
      })
    );
  });

  it('should call next middleware', () => {
    loggerMiddleware(
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(mockNext).toHaveBeenCalled();
  });

  it('should log response details when response ends', () => {
    loggerMiddleware(
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    // Clear the initial request log call
    mockLoggerInfo.mockClear();

    // Simulate response end
    (mockResponse.end as jest.Mock)();

    expect(mockLoggerInfo).toHaveBeenCalledWith(
      'HTTP Response',
      expect.objectContaining({
        method: 'GET',
        path: '/test',
        statusCode: 200,
        duration: expect.any(Number),
      })
    );
  });

  it('should include duration in response log', () => {
    loggerMiddleware(
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    mockLoggerInfo.mockClear();
    (mockResponse.end as jest.Mock)();

    const logCall = mockLoggerInfo.mock.calls[0];
    expect(logCall[1].duration).toBeGreaterThanOrEqual(0);
  });
});
