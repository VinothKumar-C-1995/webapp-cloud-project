#!/bin/bash
set -e

ENV="${1:-prod}"
ACTION="${2:-apply}"

echo "🏗️  Terraform $ACTION for environment: $ENV"

cd terraform
terraform init
terraform $ACTION -var-file="terraform.tfvars" -var="environment=$ENV" -auto-approve
echo "✅ Terraform $ACTION complete!"
