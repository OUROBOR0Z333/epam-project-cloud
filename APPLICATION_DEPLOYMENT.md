# Application Deployment Guide

This document provides information about deploying the movie-analyst application using the 2.9-deploy-application workflow.

## GitHub Secrets Required

The following secrets need to be configured in your GitHub repository for the application deployment workflow to work properly:

### Mandatory Secrets

- `GCP_PROJECT_ID` (String)
  - Your Google Cloud Project ID
  - Example: `epamgcpdeployment2`

- `GCP_REGION` (String) 
  - The region where resources are deployed
  - Example: `us-central1`

- `GCP_ZONE` (String)
  - The zone where resources are deployed
  - Example: `us-central1-a`

- `GCP_SA_KEY` (JSON string)
  - Service account key JSON for GCP authentication
  - Format: `{"type": "service_account", "project_id": "...", ...}`

- `DB_ROOT_PASSWORD` (String)
  - Root password for the database
  - Example: `your_secure_password_here`

## Service Account Configuration

The infrastructure creates two main service accounts:

1. **App Service Account**: Used by application instances (frontend and backend)
   - Name pattern: `app-sa-{workspace}@{project_id}.iam.gserviceaccount.com`
   - Used for authenticating to app instances via OS Login

2. **Bastion Service Account**: Used by the bastion host
   - Name pattern: `bastion-sa-{workspace}@{project_id}.iam.gserviceaccount.com`
   - Used for authenticating to the bastion host via OS Login

Both service accounts have the `roles/editor` role assigned to them.

## Authentication Flow

The application deployment workflow follows these authentication steps:

1. **GitHub Actions Authentication**: The workflow starts by authenticating to GCP using the `GCP_SA_KEY` secret
2. **Terraform Initialization**: Terraform is initialized with the configured backend
3. **Workspace Selection**: The appropriate Terraform workspace (qa/prod) is selected
4. **Infrastructure Information Retrieval**: The workflow retrieves infrastructure details using Terraform outputs and gcloud commands, including service account information
5. **Dynamic Inventory Creation**: Ansible inventory is created based on current infrastructure state, using appropriate service account usernames
6. **Application Deployment**: Ansible deploys the application to the infrastructure using SSH through the bastion host

## SSH Access via Service Accounts

The workflow leverages Google Cloud's OS Login feature to enable SSH access:

- The service account emails are transformed into OS Login usernames
- For example, `my-service-account@project.iam.gserviceaccount.com` becomes `sa_12345678901234567890` as an OS Login username
- The workflow discovers these usernames dynamically and uses them in the Ansible inventory

## Workflow Configuration

The workflow `2.9-deploy-application.yml` accepts the following parameters:

- `environment` (Required): Select 'qa' or 'prod' environment

## Troubleshooting

### Common Issues and Solutions

1. **"Could not determine bastion IP" Error**
   - Ensure your infrastructure has been deployed before running this workflow
   - Check that the bastion host exists in your GCP project
   - Verify the environment name matches your Terraform workspace name

2. **SSH Connection Failures**
   - Verify OS Login is enabled for your GCP project
   - Ensure the service accounts have the necessary IAM roles
   - Check that the instances have been created with the appropriate service accounts

3. **Authentication Failures**
   - Verify that `GCP_SA_KEY` contains valid JSON credentials
   - Ensure the service account has appropriate permissions (Editor role or more specific roles)
   - Check that `GCP_PROJECT_ID` matches the project in your service account key

4. **Infrastructure Information Retrieval Failures**
   - Make sure the required Terraform state exists
   - Ensure you have deployed the infrastructure before running the application deployment workflow
   - Verify that the Terraform workspace name matches the expected pattern

## Security Notes

- All sensitive data (like database passwords) are handled via GitHub secrets
- The workflow uses SSH tunneling through the bastion host to access private instances
- Database credentials are passed securely to Ansible without being logged
- Ansible host key checking is disabled to prevent deployment failures due to dynamic IP addresses