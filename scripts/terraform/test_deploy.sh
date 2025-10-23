#!/bin/bash

# test_deploy.sh - Test deploying infrastructure from a clean state

echo "🧪 Testing infrastructure deployment from clean state..."

# Navigate to the GCP deployment directory
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment

# Initialize Terraform
echo "🔄 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Apply the deployment
echo "🚀 Applying deployment..."
terraform apply -auto-approve tfplan

# Verify the deployment
echo "🔍 Verifying deployment..."
gsutil ls -p epamgcpdeployment2

echo "✅ Deployment test complete!"