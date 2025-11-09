#!/bin/bash

# ECR Deployment Script
# This script builds a Docker image and pushes it to AWS ECR
# Usage: ./scripts/deploy-to-ecr.sh <aws-region> <ecr-repository-name> <version>

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display error messages
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to display success messages
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display info messages
info() {
    echo -e "${YELLOW}$1${NC}"
}

# Validate arguments
if [ $# -ne 3 ]; then
    error "Invalid number of arguments.\nUsage: $0 <aws-region> <ecr-repository-name> <version>"
fi

AWS_REGION=$1
ECR_REPOSITORY_NAME=$2
VERSION=$3

# Validate that arguments are not empty
if [ -z "$AWS_REGION" ]; then
    error "AWS region cannot be empty"
fi

if [ -z "$ECR_REPOSITORY_NAME" ]; then
    error "ECR repository name cannot be empty"
fi

if [ -z "$VERSION" ]; then
    error "Version cannot be empty"
fi

info "Starting deployment process..."
info "AWS Region: $AWS_REGION"
info "ECR Repository: $ECR_REPOSITORY_NAME"
info "Version: $VERSION"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    error "AWS CLI is not installed. Please install it first."
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install it first."
fi

# Get AWS account ID
info "Retrieving AWS account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>&1) || error "Failed to get AWS account ID. Please check your AWS credentials."

# Construct ECR repository URI
ECR_REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}"

info "ECR Repository URI: $ECR_REPOSITORY_URI"

# Authenticate with ECR
info "Authenticating with ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REPOSITORY_URI" 2>&1 || error "Failed to authenticate with ECR"

success "Successfully authenticated with ECR"

# Build Docker image
info "Building Docker image..."
docker build -t "$ECR_REPOSITORY_NAME:$VERSION" . || error "Failed to build Docker image"

success "Successfully built Docker image"

# Tag image with version-specific tag
info "Tagging image with version $VERSION..."
docker tag "$ECR_REPOSITORY_NAME:$VERSION" "$ECR_REPOSITORY_URI:$VERSION" || error "Failed to tag image with version"

# Tag image with latest tag
info "Tagging image with 'latest' tag..."
docker tag "$ECR_REPOSITORY_NAME:$VERSION" "$ECR_REPOSITORY_URI:latest" || error "Failed to tag image with latest"

success "Successfully tagged images"

# Push version-specific tag
info "Pushing image with version tag to ECR..."
docker push "$ECR_REPOSITORY_URI:$VERSION" || error "Failed to push version-tagged image to ECR"

success "Successfully pushed $ECR_REPOSITORY_URI:$VERSION"

# Push latest tag
info "Pushing image with latest tag to ECR..."
docker push "$ECR_REPOSITORY_URI:latest" || error "Failed to push latest-tagged image to ECR"

success "Successfully pushed $ECR_REPOSITORY_URI:latest"

# Display success message with image URIs
echo ""
success "=========================================="
success "Deployment completed successfully!"
success "=========================================="
echo ""
echo "Image URIs:"
echo "  Version tag: $ECR_REPOSITORY_URI:$VERSION"
echo "  Latest tag:  $ECR_REPOSITORY_URI:latest"
echo ""
info "You can now update your ECS service to use these images."
