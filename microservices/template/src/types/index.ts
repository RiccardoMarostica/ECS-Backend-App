export interface HealthResponse {
  status: 'healthy' | 'unhealthy';
  service: string;
  version: string;
  uptime: number;
  timestamp: string;
}

export interface ErrorResponse {
  error: string;
  message: string;
  statusCode: number;
  path?: string;
  timestamp: string;
}
