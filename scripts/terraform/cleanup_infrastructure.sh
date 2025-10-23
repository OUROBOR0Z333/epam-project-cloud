#!/bin/bash

# cleanup_infrastructure.sh - Clean up all deployed infrastructure and reset Terraform state

echo "🔄 Cleaning up all deployed infrastructure..."

# Navigate to the GCP deployment directory
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment

# Destroy all Terraform-managed infrastructure
echo "🗑️  Destroying Terraform infrastructure..."
terraform destroy -auto-approve

# Remove Terraform state files for fresh testing
echo "🗑️  Removing Terraform state files..."
rm -f terraform.tfstate terraform.tfstate.backup

# Verify cleanup by listing storage buckets
echo "🔍 Verifying cleanup..."
gsutil ls -p epamgcpdeployment2 2>/dev/null || echo "✅ No storage buckets found (as expected after cleanup)"

echo "✅ Infrastructure cleanup complete!"
echo "✅ Terraform state reset for fresh testing!"