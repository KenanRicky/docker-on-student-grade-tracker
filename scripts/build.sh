#!/usr/bin/env bash
set -e

TAG=${1:-"v1.0.0"}
REGISTRY=${DOCKER_HUB_USER:-"local"}

echo "=== Building Grade Tracker Images [Tag: $TAG] ==="

# Build Frontend
echo "Building Frontend Image..."
docker build -t "${REGISTRY}/grade-tracker-frontend:${TAG}" ./frontend
echo "Frontend built successfully."

# Build Backend
echo "Building Backend Image..."
docker build -t "${REGISTRY}/grade-tracker-backend:${TAG}" ./backend
echo "Backend built successfully."

echo "=== All images built successfully! ==="