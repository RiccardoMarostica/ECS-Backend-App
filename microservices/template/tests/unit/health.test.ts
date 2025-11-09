import { Request, Response } from 'express';
import { getHealth } from '../../src/controllers/health.controller';
import { HealthResponse } from '../../src/types';

describe('Health Controller', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let jsonMock: jest.Mock;
  let statusMock: jest.Mock;

  beforeEach(() => {
    mockRequest = {};
    jsonMock = jest.fn();
    statusMock = jest.fn().mockReturnValue({ json: jsonMock });
    mockResponse = {
      status: statusMock,
      json: jsonMock,
    };
  });

  it('should return 200 status', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    expect(statusMock).toHaveBeenCalledWith(200);
  });

  it('should return healthy status', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    expect(jsonMock).toHaveBeenCalled();
    const response: HealthResponse = jsonMock.mock.calls[0][0];
    expect(response.status).toBe('healthy');
  });

  it('should include service name in response', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    const response: HealthResponse = jsonMock.mock.calls[0][0];
    expect(response.service).toBeDefined();
    expect(typeof response.service).toBe('string');
  });

  it('should include version in response', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    const response: HealthResponse = jsonMock.mock.calls[0][0];
    expect(response.version).toBeDefined();
    expect(typeof response.version).toBe('string');
  });

  it('should include uptime in response', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    const response: HealthResponse = jsonMock.mock.calls[0][0];
    expect(response.uptime).toBeDefined();
    expect(typeof response.uptime).toBe('number');
    expect(response.uptime).toBeGreaterThanOrEqual(0);
  });

  it('should include timestamp in response', () => {
    getHealth(mockRequest as Request, mockResponse as Response);

    const response: HealthResponse = jsonMock.mock.calls[0][0];
    expect(response.timestamp).toBeDefined();
    expect(typeof response.timestamp).toBe('string');
    expect(new Date(response.timestamp).toString()).not.toBe('Invalid Date');
  });
});
