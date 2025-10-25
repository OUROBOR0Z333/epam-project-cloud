# Infrastructure Deployment Workflows

This repository contains GitHub Actions workflows for deploying infrastructure using a sequential approach.

## Sequential Deployment Steps

The infrastructure is deployed in 9 sequential steps:

1. **VPC Creation** (`vpc-creation.yml`) - Creates the VPC network
2. **Subnets Creation** (`subnets-creation.yml`) - Creates public and private subnets
3. **NAT Gateway** (`nat-gateway-creation.yml`) - Creates router and NAT gateway
4. **Firewall & Security** (`firewall-security-creation.yml`) - Sets up firewall rules and security
5. **Compute Instances** (`compute-instances-creation.yml`) - Creates bastion, frontend, and backend instances
6. **Database** (`database-creation.yml`) - Sets up Cloud SQL database
7. **Load Balancer** (`load-balancer-creation.yml`) - Creates HTTP load balancer
8. **Application Deployment** (`application-deployment.yml`) - Deploys application via Ansible
9. **Master Deployment** (`master-sequential-deployment.yml`) - Orchestrates all steps in sequence

## Testing Configuration

- **Configuration Test** (`test-configuration.yml`) - Validates configuration without making changes

## How to Use

Each step can be executed independently for fine-grained control, or use the master workflow to execute the entire sequence.

All workflows are manually triggered using `workflow_dispatch` for maximum control.