# EPAM Cloud Project - GCP Deployment

## Project Status
✅ Active

## Project Information
- **Project ID**: epamgcpdeployment2
- **Project Name**: EPAM GCP Cloud Project
- **Status**: ACTIVE
- **Created**: 2025-10-21

## Billing Information
- **Billing Account**: 01C6C8-599B7A-04EFFB
- **Status**: Enabled
- **Currency**: MXN

## Authentication
- **Active Account**: jacobofp2001@gmail.com
- **Role**: Owner

## Infrastructure Status
🧹 All infrastructure has been removed

Previously deployed infrastructure:
1. ✅ Google Cloud Storage Bucket (epam-cloud-bucket-12345) - DELETED

## Terraform Configuration
The project uses a default value for the project_id variable in variables.tf:
```hcl
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
  default     = "epamgcpdeployment2"
}
```

This eliminates the need to specify the project_id in terraform.tfvars, reducing the chance of mismatches.

## Diagnostic Tools
Several diagnostic scripts have been created to help prevent and troubleshoot similar issues:

### Project Consistency Checker
- Path: `/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/check_project_consistency.sh`
- Purpose: Verifies that the gcloud project matches the Terraform project configuration and that billing is enabled
- Usage: Run from any directory containing a terraform.tfvars file

To use the script:
```bash
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment
../scripts/check_project_consistency.sh
```

### Safe Terraform Runner
- Path: `/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/tf_safe_apply.sh`
- Purpose: Automatically runs the project consistency check before executing any Terraform commands
- Usage: Run from any directory containing a terraform.tfvars file

To use the script:
```bash
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment
../scripts/tf_safe_apply.sh plan
../scripts/tf_safe_apply.sh apply -auto-approve
```

### Terraform Variable Explanation
- Path: `/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/explain_tf_vars.sh`
- Purpose: Explains Terraform variable precedence and how variables are resolved in this project

To use the script:
```bash
/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/explain_tf_vars.sh
```

### Infrastructure Cleanup
- Path: `/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/cleanup_infrastructure.sh`
- Purpose: Cleans up all deployed infrastructure and resets Terraform state for fresh testing

To use the script:
```bash
/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/cleanup_infrastructure.sh
```

### Deployment Test
- Path: `/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/test_deploy.sh`
- Purpose: Tests deploying infrastructure from a clean state

To use the script:
```bash
/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/test_deploy.sh
```

## Cleanup Instructions
To clean up all deployed infrastructure:
```bash
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment
terraform destroy -auto-approve
```

To reset Terraform state for fresh testing:
```bash
cd /home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/gcp-deployment
rm -f terraform.tfstate terraform.tfstate.backup
```

To use the automated cleanup script:
```bash
/home/ouroboroz/Projects/Epam_Cloud_Project/epam_project_gcp_deployment/scripts/cleanup_infrastructure.sh
```