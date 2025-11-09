# TypeScript Microservice Template

A production-ready TypeScript microservice template designed for AWS ECS deployment. This template provides a standardized foundation for building scalable microservices with Express.js, complete with Docker configuration, health checks, logging, testing, and automated deployment scripts.

## Overview

This template is part of the ECS Backend App infrastructure and integrates seamlessly with:
- AWS ECS (Elastic Container Service) on Fargate
- Application Load Balancer (ALB) with health checks
- Amazon ECR (Elastic Container Registry)
- AWS API Gateway
- Amazon Cognito for authentication
- CloudWatch for logging and monitoring

The template follows Node.js and TypeScript best practices, implements a clean architecture pattern, and includes everything needed to quickly create new microservices with consistent organization and quality standards.

## Features

- **TypeScript**: Full TypeScript support with strict type checking
- **Express.js**: Lightweight web framework with middleware support
- **Health Checks**: ALB-compatible health check endpoints
- **Structured Logging**: JSON-formatted logs for CloudWatch
- **Docker**: Multi-stage Dockerfile for optimized container images
- **Testing**: Jest framework with unit and integration test examples
- **Linting**: ESLint configured for TypeScript
- **Hot Reload**: Nodemon for development with automatic restarts
- **Deployment**: Automated ECR deployment script
- **Environment Config**: Type-safe environment variable management

## Prerequisites

Before using this template, ensure you have the following installed:

- **Node.js**: v18.x or higher ([Download](https://nodejs.org/))
- **npm**: v9.x or higher (comes with Node.js)
- **Docker**: v20.x or higher ([Download](https://www.docker.com/))
- **AWS CLI**: v2.x or higher ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **Terraform**: v1.5.x or higher (for infrastructure deployment) ([Download](https://www.terraform.io/downloads))

You'll also need:
- AWS account with appropriate permissions
- AWS credentials configured (`aws configure`)
- ECR repository created for your service

## Quick Start

### 1. Clone the Template

```bash
# Copy the template to create a new microservice
cp -r microservices/template microservices/my-new-service
cd microservices/my-new-service
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your configuration
# PORT=8080
# NODE_ENV=development
# SERVICE_NAME=my-new-service
# LOG_LEVEL=info
```

### 4. Start Development Server

```bash
npm run dev
```

The service will start on `http://localhost:8080`

### 5. Verify It's Running

```bash
# Check health endpoint
curl http://localhost:8080/health

# Check root endpoint
curl http://localhost:8080/
```

## Local Development

### Available Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Compile TypeScript to JavaScript
- `npm start` - Run the compiled application
- `npm test` - Run test suite
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report
- `npm run lint` - Check code style
- `npm run lint:fix` - Fix code style issues automatically
- `npm run deploy` - Deploy to ECR (requires arguments)

### Development Workflow

1. Make changes to TypeScript files in `src/`
2. The dev server will automatically restart
3. Test your changes at `http://localhost:8080`
4. Write tests in `tests/unit/` or `tests/integration/`
5. Run `npm test` to verify tests pass
6. Run `npm run lint` to check code style

### Project Structure

```
microservices/template/
├── src/
│   ├── index.ts                 # Application entry point
│   ├── app.ts                   # Express app configuration
│   ├── config/
│   │   └── index.ts            # Environment configuration
│   ├── routes/
│   │   ├── index.ts            # Route aggregator
│   │   └── health.routes.ts    # Health check routes
│   ├── controllers/
│   │   └── health.controller.ts # Health check controller
│   ├── services/               # Business logic layer
│   ├── middleware/
│   │   ├── error.middleware.ts  # Error handling
│   │   └── logger.middleware.ts # Request logging
│   ├── utils/
│   │   └── logger.ts           # Logging utility
│   └── types/
│       └── index.ts            # TypeScript type definitions
├── tests/
│   ├── unit/                   # Unit tests
│   └── integration/            # Integration tests
├── scripts/
│   └── deploy-to-ecr.sh        # ECR deployment script
├── Dockerfile                   # Multi-stage Docker build
├── package.json                # Dependencies and scripts
├── tsconfig.json               # TypeScript configuration
└── jest.config.js              # Jest test configuration
```

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

### Test Coverage

The template includes tests for:
- Health check endpoints
- Configuration loading and validation
- Logger middleware
- Error handling middleware

Coverage thresholds are set to 80% for statements, branches, functions, and lines.

### Writing Tests

**Unit Test Example** (`tests/unit/example.test.ts`):
```typescript
import { getHealth } from '../../src/controllers/health.controller';

describe('Health Controller', () => {
  it('should return health status', () => {
    // Your test implementation
  });
});
```

**Integration Test Example** (`tests/integration/example.test.ts`):
```typescript
import request from 'supertest';
import { app } from '../../src/app';

describe('GET /health', () => {
  it('should return 200 and health status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });
});
```

## Docker

### Building the Docker Image

```bash
# Build the image
docker build -t my-service:latest .

# Build with a specific version tag
docker build -t my-service:v1.0.0 .
```

### Running the Container Locally

```bash
# Run the container
docker run -p 8080:8080 \
  -e SERVICE_NAME=my-service \
  -e NODE_ENV=production \
  my-service:latest

# Run with environment file
docker run -p 8080:8080 --env-file .env my-service:latest
```

### Testing the Container

```bash
# Check health endpoint
curl http://localhost:8080/health

# Check logs
docker logs <container-id>
```

### Docker Image Details

The Dockerfile uses a multi-stage build:
- **Stage 1 (Builder)**: Installs all dependencies and compiles TypeScript
- **Stage 2 (Production)**: Copies only production dependencies and compiled code

Benefits:
- Smaller image size (typically 50-100MB)
- Faster deployment times
- Improved security (no dev tools in production image)
- Runs as non-root user

## Deployment

### ECR Deployment

The template includes an automated script for deploying to Amazon ECR.

#### Prerequisites

1. Create an ECR repository:
```bash
aws ecr create-repository \
  --repository-name my-service \
  --region eu-west-1
```

2. Ensure AWS credentials are configured:
```bash
aws configure
```

#### Deploy to ECR

```bash
# Usage: ./scripts/deploy-to-ecr.sh <aws-region> <ecr-repository-name> <version>

# Example:
./scripts/deploy-to-ecr.sh eu-west-1 my-service v1.0.0
```

The script will:
1. Authenticate with ECR
2. Build the Docker image
3. Tag the image with both the version and "latest"
4. Push both tags to ECR
5. Display the image URIs

#### Manual ECR Deployment

If you prefer to deploy manually:

```bash
# Authenticate with ECR
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com

# Build the image
docker build -t my-service:v1.0.0 .

# Tag the image
docker tag my-service:v1.0.0 <account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-service:v1.0.0
docker tag my-service:v1.0.0 <account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-service:latest

# Push to ECR
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-service:v1.0.0
docker push <account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-service:latest
```

### ECS Deployment with Terraform

After pushing your image to ECR, deploy to ECS using Terraform:

#### 1. Create Terraform Configuration

Create a new file in `terraform/envs/<environment>/` (e.g., `my-service.tf`):

```hcl
module "my_service" {
  source = "../../modules/ecs/service"
  
  # Service Configuration
  service_name     = "my-service"
  container_image  = "<account-id>.dkr.ecr.eu-west-1.amazonaws.com/my-service:latest"
  container_port   = 8080
  
  # Routing Configuration
  path_pattern     = ["/my-service", "/my-service/*"]
  health_check_path = "/health"
  
  # Resource Configuration
  cpu              = 256
  memory           = 512
  desired_count    = 2
  
  # Network Configuration
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  alb_listener_arn = module.alb.listener_arn
  alb_security_group_id = module.alb.security_group_id
  
  # Environment Variables
  environment_variables = {
    SERVICE_NAME = "my-service"
    NODE_ENV     = "production"
    LOG_LEVEL    = "info"
  }
  
  # Tags
  tags = {
    Environment = "production"
    Service     = "my-service"
  }
}
```

#### 2. Deploy with Terraform

```bash
cd terraform/envs/production

# Initialize Terraform (first time only)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply
```

#### 3. Verify Deployment

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster <cluster-name> \
  --services my-service \
  --region eu-west-1

# Test the deployed service
curl https://<alb-dns-name>/my-service/health
```

## Customization Guide

### Creating a New Microservice from Template

1. **Copy the template**:
   ```bash
   cp -r microservices/template microservices/my-new-service
   cd microservices/my-new-service
   ```

2. **Update package.json**:
   - Change `name` to your service name
   - Update `description`
   - Update `author`

3. **Update environment variables**:
   - Edit `.env.example` with service-specific variables
   - Update `src/config/index.ts` to add new config fields

4. **Add your business logic**:
   - Create services in `src/services/`
   - Create controllers in `src/controllers/`
   - Create routes in `src/routes/`
   - Update `src/routes/index.ts` to register new routes

5. **Add tests**:
   - Create unit tests in `tests/unit/`
   - Create integration tests in `tests/integration/`

6. **Update documentation**:
   - Update this README with service-specific information
   - Document your API endpoints
   - Add any service-specific setup instructions

### Adding a New Endpoint

1. **Create a controller** (`src/controllers/example.controller.ts`):
```typescript
import { Request, Response } from 'express';

export const getExample = async (req: Request, res: Response): Promise<void> => {
  res.json({ message: 'Example endpoint' });
};
```

2. **Create routes** (`src/routes/example.routes.ts`):
```typescript
import { Router } from 'express';
import { getExample } from '../controllers/example.controller';

export const exampleRouter = Router();

exampleRouter.get('/example', getExample);
```

3. **Register routes** (`src/routes/index.ts`):
```typescript
import { exampleRouter } from './example.routes';

router.use('/api', exampleRouter);
```

4. **Add tests** (`tests/integration/example.test.ts`):
```typescript
import request from 'supertest';
import { app } from '../../src/app';

describe('GET /api/example', () => {
  it('should return example data', async () => {
    const response = await request(app).get('/api/example');
    expect(response.status).toBe(200);
  });
});
```

### Adding Database Support

1. **Install database client**:
```bash
npm install pg  # PostgreSQL
# or
npm install @aws-sdk/client-dynamodb  # DynamoDB
```

2. **Create database configuration** (`src/config/database.ts`):
```typescript
export const databaseConfig = {
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  // ... other config
};
```

3. **Create repository layer** (`src/repositories/`):
```typescript
export class UserRepository {
  async findById(id: string) {
    // Database query logic
  }
}
```

4. **Initialize connection** in `src/index.ts` before starting server

### Adding Authentication

1. **Install JWT library**:
```bash
npm install jsonwebtoken
npm install --save-dev @types/jsonwebtoken
```

2. **Create auth middleware** (`src/middleware/auth.middleware.ts`):
```typescript
import { Request, Response, NextFunction } from 'express';

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
  // Verify JWT token
  // Add user to request object
  next();
};
```

3. **Protect routes**:
```typescript
router.get('/protected', authMiddleware, protectedController);
```

## API Documentation

### Endpoints

#### GET /health

Health check endpoint for ALB monitoring.

**Response** (200 OK):
```json
{
  "status": "healthy",
  "service": "typescript-microservice-template",
  "version": "1.0.0",
  "uptime": 123.45,
  "timestamp": "2025-11-09T12:00:00.000Z"
}
```

#### GET /

Root endpoint returning service information.

**Response** (200 OK):
```json
{
  "service": "typescript-microservice-template",
  "version": "1.0.0",
  "description": "Production-ready TypeScript microservice template for AWS ECS deployment"
}
```

### Error Responses

All errors return a consistent JSON format:

```json
{
  "error": "ErrorType",
  "message": "Human-readable error message",
  "statusCode": 500,
  "path": "/api/endpoint",
  "timestamp": "2025-11-09T12:00:00.000Z"
}
```

**Common Status Codes**:
- `200` - Success
- `400` - Bad Request (validation errors)
- `404` - Not Found
- `500` - Internal Server Error

## Environment Variables

### Required Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PORT` | HTTP server port | `8080` | `8080` |
| `NODE_ENV` | Environment name | `development` | `production` |
| `SERVICE_NAME` | Microservice name | `typescript-microservice-template` | `my-service` |

### Optional Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `LOG_LEVEL` | Logging level | `info` | `debug`, `info`, `warn`, `error` |

### Setting Environment Variables

**Local Development** (`.env` file):
```bash
PORT=8080
NODE_ENV=development
SERVICE_NAME=my-service
LOG_LEVEL=debug
```

**Docker**:
```bash
docker run -e SERVICE_NAME=my-service -e NODE_ENV=production my-service:latest
```

**ECS (Terraform)**:
```hcl
environment_variables = {
  SERVICE_NAME = "my-service"
  NODE_ENV     = "production"
  LOG_LEVEL    = "info"
}
```

## Logging

### Log Format

All logs use JSON format for CloudWatch compatibility:

```json
{
  "timestamp": "2025-11-09T12:00:00.000Z",
  "level": "info",
  "message": "HTTP Request",
  "method": "GET",
  "path": "/health",
  "statusCode": 200,
  "duration": 5
}
```

### Log Levels

- `debug` - Detailed debugging information (disabled in production)
- `info` - General informational messages (requests, startup)
- `warn` - Warning messages (deprecated features, slow responses)
- `error` - Error messages (exceptions, failures)

### Using the Logger

```typescript
import { logger } from './utils/logger';

logger.info('User created', { userId: '123' });
logger.error('Database connection failed', { error: err.message });
```

## Troubleshooting

### Common Issues

#### Port Already in Use

**Error**: `Error: listen EADDRINUSE: address already in use :::8080`

**Solution**:
```bash
# Find process using port 8080
lsof -i :8080

# Kill the process
kill -9 <PID>

# Or use a different port
PORT=3000 npm run dev
```

#### TypeScript Compilation Errors

**Error**: `error TS2304: Cannot find name 'X'`

**Solution**:
```bash
# Install missing type definitions
npm install --save-dev @types/X

# Clean and rebuild
rm -rf dist node_modules
npm install
npm run build
```

#### Docker Build Fails

**Error**: `npm ERR! code ENOENT`

**Solution**:
- Ensure `package.json` and `package-lock.json` exist
- Check `.dockerignore` isn't excluding necessary files
- Try building without cache: `docker build --no-cache -t my-service .`

#### ECR Authentication Fails

**Error**: `Error: Cannot perform an interactive login from a non TTY device`

**Solution**:
```bash
# Ensure AWS CLI is configured
aws configure

# Test AWS credentials
aws sts get-caller-identity

# Re-authenticate with ECR
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-1.amazonaws.com
```

#### Tests Failing

**Error**: Tests fail with timeout or connection errors

**Solution**:
```bash
# Ensure no dev server is running
# Kill any processes on port 8080

# Clear Jest cache
npm test -- --clearCache

# Run tests with verbose output
npm test -- --verbose
```

#### Container Exits Immediately

**Error**: Container starts then exits with code 1

**Solution**:
```bash
# Check container logs
docker logs <container-id>

# Run container interactively to debug
docker run -it my-service:latest sh

# Verify environment variables are set
docker run -e NODE_ENV=production my-service:latest
```

### Getting Help

If you encounter issues not covered here:

1. Check the application logs for error messages
2. Verify all prerequisites are installed and configured
3. Ensure environment variables are set correctly
4. Review the CloudWatch logs for deployed services
5. Check AWS ECS service events for deployment issues

## License

MIT

## Contributing

When contributing to this template:

1. Follow the existing code style
2. Run `npm run lint` before committing
3. Ensure all tests pass with `npm test`
4. Update documentation for any changes
5. Keep the template minimal and focused on core functionality

