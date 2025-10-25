# Infrastructure Deployment Workflows

This repository contains GitHub Actions workflows for deploying infrastructure using a sequential approach.

## Foundation Workflows (1.n-foundation-*)

### Test Workflows
1. **`basic-test.yml`** - Simple echo commands to verify GitHub Actions
2. **`gcp-test.yml`** - Test GCP connectivity and authentication
3. **`terraform-gcp-test.yml`** - Test Terraform configuration validation
4. **`gcp-auth-test.yml`** - Test GCP authentication with service account

### Infrastructure Setup Workflows
1. **`create-bucket.yml`** - Create GCS bucket for Terraform state storage
2. **`delete-bucket.yml`** - Delete GCS bucket (optional)
3. **`configure-backend.yml`** - Configure Terraform to use GCS backend

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