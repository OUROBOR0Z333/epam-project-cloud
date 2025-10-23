#!/bin/bash

# Script to set up Terraform backend configuration for team collaboration

set -e  # Exit on any error

echo "Setting up Terraform backend configuration..."

# Ensure we're in the right directory
cd "$(dirname "$0")/../gcp-deployment"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply the configuration to create the GCS bucket for backend storage
echo "Applying configuration to create GCS bucket..."
terraform apply -auto-approve

# Create backend configuration file
cat > backend.hcl << EOF
bucket = "tf-bucket-epgcp"
prefix = "terraform/state"
EOF

echo "Backend configuration file created: backend.hcl"

# Now initialize with the backend configuration
echo "Reinitializing with backend configuration..."
terraform init -backend-config=backend.hcl

echo "Terraform backend setup completed successfully!"
echo "Team members can now use this backend by running: terraform init -backend-config=backend.hcl"