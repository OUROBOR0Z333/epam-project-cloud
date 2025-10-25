# Infrastructure Deployment Workflows

This repository contains GitHub Actions workflows for deploying infrastructure using a sequential approach.

## Foundation Workflows (1.n-foundation-*)

### Test Workflows
1. **`1.1-foundation-basic-test.yml`** - Simple echo commands to verify GitHub Actions
2. **`1.2-foundation-gcp-test.yml`** - Test GCP connectivity and authentication
3. **`1.3-foundation-terraform-gcp-test.yml`** - Test Terraform configuration validation
4. **`1.4-foundation-gcp-auth-test.yml`** - Test GCP authentication with service account

### Infrastructure Setup Workflows
1. **`1.5-foundation-create-bucket.yml`** - Create GCS bucket for Terraform state storage
2. **`1.6-foundation-delete-bucket.yml`** - Delete GCS bucket (optional)
3. **`1.7-foundation-configure-backend.yml`** - Configure Terraform to use GCS backend

## Troubleshooting Authentication Issues

If you encounter authentication errors like "google-github-actions/auth failed with: the GitHub Action workflow must specify exactly one of 'workload_identity_provider' or 'credentials_json'", consider the following:

### Common Causes:
1. **Missing GitHub Secrets** - Ensure all required secrets are properly set in your repository settings:
   - `GCP_SA_KEY` (Service Account Key JSON)
   - `GCP_PROJECT_ID`
   - `GCP_REGION`
   - `TERRAFORM_STATE_BUCKET`

2. **PR from Forks** - Secrets are not available by default for pull requests from forks for security reasons. Workflows will fail if triggered by PRs from forks.

3. **Incorrectly Formatted Service Account Key** - The `GCP_SA_KEY` secret must contain a properly formatted JSON service account key.

### Solutions:
1. **Add Missing Secrets**: Go to your repository Settings > Secrets and variables > Actions and add all required secrets.

2. **Proper Service Account Key Format**: The `GCP_SA_KEY` should be a base64-encoded JSON key file. You can encode it using:
   ```bash
   cat path/to/your/service-account-key.json | base64
   ```

3. **For PR workflows**: If you need the workflows to run on PRs, consider using Workload Identity Federation instead of service account keys, or ensure PRs are created from branches in the same repository rather than from forks.

## Infrastructure Deployment Steps (2.n-infrastructure-*)

1. **`2.1-infrastructure-vpc-creation.yml`** - Creates the VPC network
2. **`2.2-infrastructure-subnets-creation.yml`** - Creates public and private subnets
3. **`2.3-infrastructure-nat-gateway-creation.yml`** - Creates router and NAT gateway
4. **`2.4-infrastructure-firewall-security-creation.yml`** - Sets up firewall rules and security
5. **`2.5-infrastructure-compute-instances-creation.yml`** - Creates bastion, frontend, and backend instances
6. **`2.6-infrastructure-database-creation.yml`** - Sets up Cloud SQL database
7. **`2.7-infrastructure-load-balancer-creation.yml`** - Creates HTTP load balancer
8. **`2.8-infrastructure-application-deployment.yml`** - Deploys application via Ansible
9. **`2.9-infrastructure-test-configuration.yml`** - Validates configuration without making changes

## Full Deployment Workflows (3.n-full-*)

1. **`3.1-full-deploy-infrastructure.yml`** - Complete infrastructure deployment workflow
2. **`3.2-full-complete-deployment.yml`** - Authentication and deployment workflow
3. **`3.3-full-master-sequential-deployment.yml`** - Orchestrates all sequential steps in order

## Configuration

Before running the workflows, ensure you have properly configured all required secrets in your GitHub repository. Refer to the [SECRETS_CONFIGURATION.md](SECRETS_CONFIGURATION.md) file for detailed instructions on setting up the required secrets, especially the `TERRAFORM_STATE_BUCKET` secret which commonly causes issues if not configured correctly.

## How to Use

All workflows are manually triggered using `workflow_dispatch` for maximum control. 

### Recommended Execution Order:

1. **Foundation Setup**:
   - Run `basic-test.yml` to verify GitHub Actions environment
   - Run `gcp-test.yml` to test GCP connectivity
   - Run `create-bucket.yml` to create GCS bucket for Terraform state
   - Run `configure-backend.yml` to configure Terraform to use GCS backend
   - Run `gcp-auth-test.yml` to verify GCP authentication

2. **Infrastructure Deployment**:
   - Run infrastructure workflows sequentially (2.1 through 2.9)
   - OR use one of the full deployment workflows (3.n)

### Environment Selection:

Most workflows support environment selection through manual inputs:
- **dev** - Development environment
- **staging** - Staging environment  
- **prod** - Production environment

## Workflow Categories

Workflows are organized into categories based on their purpose:

### Foundation Workflows (Test & Setup)
These workflows prepare the environment and verify prerequisites before infrastructure deployment.
- Authentication testing
- Basic environment validation
- Terraform backend configuration
- GCS bucket management

### Infrastructure Workflows (Sequential Deployment)
These workflows deploy infrastructure components in a specific sequence:
1. Network (VPC, Subnets)
2. Gateways (NAT, Internet)
3. Security (Firewalls, Rules)
4. Compute (Instances, VMs)
5. Database (Cloud SQL)
6. Load Balancing
7. Application Deployment

### Full Deployment Workflows
These workflows orchestrate complete deployment sequences for automated execution.