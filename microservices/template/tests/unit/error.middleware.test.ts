import { Request, Response, NextFunction } from 'express';
import { errorMiddleware } from '../../src/middleware/error.middleware';
import { logger } from '../../src/utils/logger';
import { ErrorResponse } from '../../src/types';

jest.mock('../../src/utils/logger');

describe('Error Middleware', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let mockNext: NextFunction;
  let mockLoggerError: jest.Mock;
  let jsonMock: jest.Mock;
  let statusMock: jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();

    mockRequest = {
      path: '/test',
      method: 'GET',
    };

    jsonMock = jest.fn();
    statusMock = jest.fn().mockReturnValue({ json: jsonMock });
    mockResponse = {
      status: statusMock,
      json: jsonMock,
    };

    mockNext = jest.fn();
    mockLoggerError = jest.fn();
    (logger.error as jest.Mock) = mockLoggerError;
  });

  it('should log error details', () => {
    const error = new Error('Test error');
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(mockLoggerError).toHaveBeenCalledWith(
      'Unhandled error',
      expect.objectContaining({
        error: 'Error',
        message: 'Test error',
        stack: expect.any(String),
        path: '/test',
        method: 'GET',
      })
    );
  });

  it('should return 500 status code for generic errors', () => {
    const error = new Error('Test error');
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(statusMock).toHaveBeenCalledWith(500);
  });

  it('should return custom status code if provided', () => {
    const error: any = new Error('Not found');
    error.statusCode = 404;
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(statusMock).toHaveBeenCalledWith(404);
  });

  it('should return formatted error response', () => {
    const error = new Error('Test error');
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    expect(jsonMock).toHaveBeenCalled();
    const response: ErrorResponse = jsonMock.mock.calls[0][0];
    
    expect(response.error).toBe('Error');
    expect(response.message).toBe('Test error');
    expect(response.statusCode).toBe(500);
    expect(response.path).toBe('/test');
    expect(response.timestamp).toBeDefined();
  });

  it('should include timestamp in error response', () => {
    const error = new Error('Test error');
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    const response: ErrorResponse = jsonMock.mock.calls[0][0];
    expect(new Date(response.timestamp).toString()).not.toBe('Invalid Date');
  });

  it('should handle errors without name', () => {
    const error: any = { message: 'Anonymous error' };
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    const response: ErrorResponse = jsonMock.mock.calls[0][0];
    expect(response.error).toBe('InternalServerError');
  });

  it('should handle errors without message', () => {
    const error: any = new Error();
    error.message = '';
    
    errorMiddleware(
      error,
      mockRequest as Request,
      mockResponse as Response,
      mockNext
    );

    const response: ErrorResponse = jsonMock.mock.calls[0][0];
    expect(response.message).toBe('An unexpected error occurred');
  });
});
