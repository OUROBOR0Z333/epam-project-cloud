#!/bin/bash

# Local Cleanup Script for EPAM Cloud Project

set -e  # Exit on any error

echo "========================================="
echo "EPAM Cloud Project - Local Cleanup"
echo "========================================="

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Cannot proceed with cleanup."
    exit 1
fi

# Check if local deployment exists
if [ ! -f "terraform/terraform.tfstate" ]; then
    echo "No local deployment found. Nothing to clean up."
    exit 0
fi

# Run Terraform destroy
echo "Destroying local deployment..."
cd terraform
terraform destroy -auto-approve
echo "✓ Local deployment destroyed"

# Clean up temporary files
echo "Cleaning up temporary files..."
cd ../ansible
rm -f local_deployment.log
rm -rf /tmp/Epam_Cloud_Project_local

echo
echo "========================================="
echo "Local cleanup completed successfully!"
echo "========================================="