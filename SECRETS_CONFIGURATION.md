# Terraform Backend Configuration Guide

This guide explains how to properly configure the secrets required for the Terraform backend workflow.

## Required Secrets

The following secrets need to be configured in your GitHub repository:

### GCP_PROJECT_ID
- **Description**: Your Google Cloud Project ID
- **Format**: String (e.g., `my-gcp-project-123456`)
- **Example**: `epamgcpdeployment2`

### GCP_REGION
- **Description**: The region where resources will be deployed
- **Format**: Valid GCP region identifier
- **Example**: `us-central1`

### GCP_SA_KEY
- **Description**: Service account key JSON for authentication
- **Format**: JSON string containing the service account credentials
- **Example**: `{"type": "service_account", "project_id": "...", ...}`

### TERRAFORM_STATE_BUCKET
- **Description**: The name of the GCS bucket for storing Terraform state
- **Format**: Valid GCS bucket name (3-222 characters, lowercase letters, numbers, hyphens, and dots)
- **Note**: DO NOT include `gs://` prefix
- **Valid Example**: `my-terraform-state-bucket-2025`
- **Invalid Examples**: 
  - `gs://my-terraform-state-bucket-2025` ❌ (includes prefix)
  - `https://my-terraform-state-bucket-2025` ❌ (includes prefix)
  - `MyTerraformBucket` ❌ (uppercase letters)
  - `my_terraform_bucket` ❌ (underscores not allowed)

## GCS Bucket Naming Rules

The `TERRAFORM_STATE_BUCKET` secret must follow these rules:
1. 3-222 characters long
2. Contain only lowercase letters, numeric characters, dashes (-), and dots (.)
3. Begin and end with a letter or number
4. Not be formatted as a domain name (e.g., `example.com`)
5. Not contain consecutive periods
6. Not contain dashes adjacent to periods
7. Not contain dots or dashes at the beginning or end of the name

## Common Issues and Solutions

### Issue: "CommandException: 'mb' command does not support provider-only URLs"
**Cause**: The `TERRAFORM_STATE_BUCKET` secret contains a prefix like `gs://`
**Solution**: Remove the `gs://` prefix from the bucket name in the secret

### Issue: "Bucket name is invalid"
**Cause**: The bucket name violates GCS naming rules
**Solution**: Use a compliant bucket name (lowercase letters, numbers, hyphens, and dots only)

### Issue: "AccessDeniedException"
**Cause**: The service account doesn't have sufficient permissions
**Solution**: Ensure your service account has the necessary roles:
- `roles/storage.admin` (for bucket creation and management)
- `roles/editor` or equivalent permissions for other GCP resources