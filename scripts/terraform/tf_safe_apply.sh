#!/bin/bash

# tf_safe_apply.sh - Run Terraform with automatic project consistency checking

# Check project consistency first
echo "Running project consistency check..."
if ! ../scripts/check_project_consistency.sh; then
    echo "❌ Project consistency check failed. Aborting Terraform operation."
    exit 1
fi

echo "✅ Project consistency check passed. Proceeding with Terraform operation."

# Run the requested Terraform command
echo "Executing: terraform $@"
terraform "$@"