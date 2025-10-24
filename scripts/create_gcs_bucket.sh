#!/bin/bash

# Script to create a Google Cloud Storage bucket for Terraform state

# Set variables
BUCKET_NAME="epam-bucket-gcp2025"
PROJECT_ID="epamgcpdeployment2"
LOCATION="us-central1"

echo "Creating Google Cloud Storage bucket: $BUCKET_NAME"
echo "Project: $PROJECT_ID"
echo "Location: $LOCATION"
echo

# Create the bucket
gsutil mb -p $PROJECT_ID -c STANDARD -l $LOCATION gs://$BUCKET_NAME/

# Check if the bucket creation was successful
if [ $? -eq 0 ]; then
    echo
    echo "✅ Bucket $BUCKET_NAME created successfully!"
    echo
    echo "Setting up bucket configuration..."
    
    # Enable versioning to keep multiple versions of objects
    gsutil versioning set on gs://$BUCKET_NAME/
    
    # Set a retention policy (optional - remove if not needed)
    # gsutil retention set 1d gs://$BUCKET_NAME/  # 1 day retention (for testing)
    
    echo
    echo "✅ Bucket configuration completed!"
    echo
    echo "Bucket URL: gs://$BUCKET_NAME/"
    echo "Project: $PROJECT_ID"
    echo
    echo "Now you can update your Terraform backend configuration to use this bucket."
    echo
    # List the bucket to verify
    gsutil ls | grep $BUCKET_NAME
else
    echo
    echo "❌ Error creating bucket. Please check the following:"
    echo "  - Make sure you're authenticated with gcloud (gcloud auth login)"
    echo "  - Verify your project ID is correct: $PROJECT_ID"
    echo "  - Check that you have permissions to create buckets in this project"
    echo "  - Ensure the bucket name $BUCKET_NAME is globally unique (it might already exist)"
    exit 1
fi