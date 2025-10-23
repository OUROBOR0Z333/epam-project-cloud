#!/bin/bash

# Script to authenticate GitHub Actions with GCP
# This script will be used in the GitHub Actions workflow

set -e  # Exit on any error

echo "Setting up GCP authentication for GitHub Actions..."

# Create a temporary file for the service account key
SERVICE_ACCOUNT_KEY_FILE=$(mktemp)

# Decode the base64 encoded key and save to the temporary file
echo "$GCP_SA_KEY" | base64 -d > "$SERVICE_ACCOUNT_KEY_FILE"

# Set up the GCP CLI with the service account
gcloud auth activate-service-account --key-file="$SERVICE_ACCOUNT_KEY_FILE"

# Set the GCP project
gcloud config set project "$GCP_PROJECT_ID"

# Set the GCP region
gcloud config set compute/region "$GCP_REGION"

echo "GCP authentication setup completed successfully!"

# Clean up: Remove the temporary file
rm "$SERVICE_ACCOUNT_KEY_FILE"

echo "GCP authentication environment is ready for Terraform operations."