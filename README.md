# Infrastructure Deployment Workflows

This repository contains GitHub Actions workflows for deploying infrastructure using a sequential approach.

## Foundation Workflows (1.n-foundation-*)

1. **Configure Backend** (`1.1-foundation-configure-backend.yml`) - Configures GCS bucket for Terraform state
2. **GCP Authentication Test** (`1.2-foundation-gcp-auth-test.yml`) - Tests authentication to GCP
3. **Basic Test** (`1.3-foundation-basic-test.yml`) - Basic test functionality

## Infrastructure Deployment Steps (2.n-infrastructure-*)

1. **VPC Creation** (`2.1-infrastructure-vpc-creation.yml`) - Creates the VPC network
2. **Subnets Creation** (`2.2-infrastructure-subnets-creation.yml`) - Creates public and private subnets
3. **NAT Gateway** (`2.3-infrastructure-nat-gateway-creation.yml`) - Creates router and NAT gateway
4. **Firewall & Security** (`2.4-infrastructure-firewall-security-creation.yml`) - Sets up firewall rules and security
5. **Compute Instances** (`2.5-infrastructure-compute-instances-creation.yml`) - Creates bastion, frontend, and backend instances
6. **Database** (`2.6-infrastructure-database-creation.yml`) - Sets up Cloud SQL database
7. **Load Balancer** (`2.7-infrastructure-load-balancer-creation.yml`) - Creates HTTP load balancer
8. **Application Deployment** (`2.8-infrastructure-application-deployment.yml`) - Deploys application via Ansible

## Additional Infrastructure Workflows

- **Configuration Test** (`2.9-infrastructure-test-configuration.yml`) - Validates configuration without making changes

## Full Deployment Workflows (3.n-full-*)

- **Deploy Infrastructure** (`3.1-full-deploy-infrastructure.yml`) - Complete infrastructure deployment workflow
- **Complete Deployment** (`3.2-full-complete-deployment.yml`) - Authentication and deployment workflow
- **Master Sequential Deployment** (`3.3-full-master-sequential-deployment.yml`) - Orchestrates all sequential steps in order

## How to Use

All workflows are manually triggered using `workflow_dispatch` for maximum control. You can execute foundation workflows first, then use either the sequential workflow approach or the complete deployment workflows.