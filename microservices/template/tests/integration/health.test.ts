import request from 'supertest';
import { app } from '../../src/app';
import { HealthResponse } from '../../src/types';
import { describe, it } from 'node:test';

describe('GET /health', () => {
  it('should return HTTP 200', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
  });

  it('should return JSON with status "healthy"', async () => {
    const response = await request(app).get('/health');
    expect(response.body.status).toBe('healthy');
  });

  it('should return JSON content type', async () => {
    const response = await request(app).get('/health');
    expect(response.headers['content-type']).toMatch(/json/);
  });

  it('should include service name in response', async () => {
    const response = await request(app).get('/health');
    const body: HealthResponse = response.body;
    
    expect(body.service).toBeDefined();
    expect(typeof body.service).toBe('string');
  });

  it('should include version in response', async () => {
    const response = await request(app).get('/health');
    const body: HealthResponse = response.body;
    
    expect(body.version).toBeDefined();
    expect(typeof body.version).toBe('string');
  });

  it('should include uptime in response', async () => {
    const response = await request(app).get('/health');
    const body: HealthResponse = response.body;
    
    expect(body.uptime).toBeDefined();
    expect(typeof body.uptime).toBe('number');
    expect(body.uptime).toBeGreaterThanOrEqual(0);
  });

  it('should include timestamp in response', async () => {
    const response = await request(app).get('/health');
    const body: HealthResponse = response.body;
    
    expect(body.timestamp).toBeDefined();
    expect(typeof body.timestamp).toBe('string');
    expect(new Date(body.timestamp).toString()).not.toBe('Invalid Date');
  });
});
