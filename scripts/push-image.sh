#!/bin/bash
set -e

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="236280552057.dkr.ecr.$REGION.amazonaws.com"
REPO="webapp"
TAG="${1:-latest}"

echo "📦 Building Docker image..."
docker build -t $REPO:$TAG .

echo "🔐 Authenticating to ECR..."
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_URL

echo "🏷️  Tagging image..."
docker tag $REPO:$TAG $ECR_URL/$REPO:$TAG

echo "🚀 Pushing image to ECR..."
docker push $ECR_URL/$REPO:$TAG

echo "✅ Done! Image: $ECR_URL/$REPO:$TAG"
