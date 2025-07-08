#!/bin/bash
# Script to build and publish Alpha Miner Docker image

set -e  # Exit on error

# Configuration
IMAGE_NAME="unicitynetwork/alpha-miner"
DOCKERFILE_PATH="docker/Dockerfile"

# Script usage
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Build and publish Alpha Miner Docker image"
  echo ""
  echo "Options:"
  echo "  -v, --version VERSION   Specify the version tag (default: latest)"
  echo "  -p, --push              Push the image to Docker Hub"
  echo "  -h, --help              Show this help message"
  exit 1
}

# Default values
VERSION="latest"
PUSH=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -p|--push)
      PUSH=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Get current Git version for the image label
GIT_VERSION=$(git describe --tags --always --dirty)
GIT_COMMIT=$(git rev-parse --short HEAD)
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "========================================="
echo "Building Alpha Miner Docker Image"
echo "Version: $VERSION"
echo "Git Commit: $GIT_COMMIT"
echo "Build Date: $BUILD_DATE"
echo "========================================="

# Build the Docker image
docker build \
  --build-arg GIT_COMMIT="$GIT_COMMIT" \
  --build-arg VERSION="$VERSION" \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  -t "$IMAGE_NAME:$VERSION" \
  -f "$DOCKERFILE_PATH" .

# Tag as latest if the version is not "latest"
if [ "$VERSION" != "latest" ]; then
  docker tag "$IMAGE_NAME:$VERSION" "$IMAGE_NAME:latest"
  echo "Tagged as $IMAGE_NAME:latest"
fi

echo "Image built successfully: $IMAGE_NAME:$VERSION"

# Push the image if requested
if [ "$PUSH" = true ]; then
  echo "Pushing image to Docker Hub..."
  
  # First, check if user is logged in to Docker Hub
  if ! docker info | grep -q "Username"; then
    echo "Error: You need to log in to Docker Hub first."
    echo "Run: docker login"
    exit 1
  fi
  
  # Push the version tag
  docker push "$IMAGE_NAME:$VERSION"
  
  # Push the latest tag if the version is not "latest"
  if [ "$VERSION" != "latest" ]; then
    docker push "$IMAGE_NAME:latest"
  fi
  
  echo "Image pushed successfully to Docker Hub."
fi

echo "Done!"