# EPAM Cloud Project - Tool Setup and Usage Guide

## Current Status
Based on the check_tools.sh script output, here's what's installed:

✓ **pyenv**: 2.6.8 - Python version manager  
✓ **tfenv**: 3.0.0 - Terraform version manager  
✓ **Terraform**: Managed by tfenv, but no default version set  
✓ **Ansible**: Installed via pyenv, using ansible-env-epam environment  
✓ **AWS CLI**: Available (aws-cli/2.31.9)  
✓ **Azure CLI**: Available (azure-cli/2.77.0)  
✓ **Google Cloud CLI**: Available (Google Cloud SDK 542.0.0)  
✓ **Python**: 3.13.5, managed by pyenv

## Setting up the Required Tools

### 1. Set up Terraform version
```bash
# List available Terraform versions
tfenv list

# Install and use a specific version (e.g., 1.9.5)
tfenv install 1.9.5
tfenv use 1.9.5

# Verify
terraform version
```

### 2. Set up Ansible in a dedicated environment
Your Ansible is already installed in a pyenv virtual environment (ansible-env-epam). To use it:

```bash
# Activate the dedicated Ansible environment
pyenv activate ansible-env-epam

# Verify Ansible
ansible --version

# When done, deactivate
deactivate
```

### 3. Cloud Provider Setup
Choose one cloud provider based on your project requirements:

#### For AWS:
```bash
# Configure AWS credentials
aws configure
```

#### For Azure:
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "your-subscription-id"
```

#### For GCP:
```bash
# Initialize gcloud
gcloud init

# Set project
gcloud config set project "your-project-id"
```

## Project Initialization

### 1. Clone the application repository
```bash
cd /home/ouroboroz/Projects/Epam_Cloud_Project
git clone https://github.com/aljoveza/devops-rampup.git app-source
```

### 2. Create Terraform configuration
```bash
# Create Terraform directory
mkdir -p terraform/{qa,prod}

# Initialize Terraform
cd terraform
terraform init
```

### 3. Set up remote state (for team collaboration)
Follow the guidelines for your chosen cloud provider:
- AWS: https://aws.amazon.com/blogs/devops/best-practices-for-managing-terraform-state-files-in-aws-ci-cd-pipeline/
- Azure: https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
- GCP: https://cloud.google.com/docs/terraform/resource-management/store-state

## Common Commands

### Terraform
```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Plan changes (without applying)
terraform plan

# Apply configuration
terraform apply

# Create workspace for different environments
terraform workspace new qa
terraform workspace new prod
```

### Ansible
```bash
# Activate Ansible environment
pyenv activate ansible-env-epam

# Check Ansible version
ansible --version

# Run Ansible playbook
ansible-playbook playbook.yml

# Check Ansible configuration
ansible-config dump --only-changed
```

### Cloud CLIs
```bash
# AWS
aws ec2 describe-instances

# Azure
az vm list

# GCP
gcloud compute instances list
```

## Troubleshooting

If you encounter issues with pyenv environments:
```bash
# List all pyenv environments
pyenv versions

# Reinstall the ansible environment if needed
pyenv virtualenv 3.10.13 ansible-env-epam
pyenv activate ansible-env-epam
pip install ansible
```

## Scripts Available

### check_tools.sh
A script to verify the installation of all required tools:
- Run with: `./check_tools.sh`
- Checks for pyenv, tfenv, Terraform, Ansible, and Cloud CLIs
- Verifies Ansible is installed in a dedicated pyenv environment
- Provides activation commands for environments
- Shows current environment status

## Local Development Setup

### Prerequisites

1. Install Terraform using tfenv:
   ```bash
   tfenv install 1.9.5
   tfenv use 1.9.5
   ```

2. Verify tools installation:
   ```bash
   ./check_tools.sh
   ```

### Local Deployment

You can either run the steps manually or use the automated deployment script.

#### Manual Deployment Steps

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Run Terraform plan to see what would be deployed:
   ```bash
   terraform plan
   ```

4. Apply the configuration locally (simulated):
   ```bash
   terraform apply
   ```

5. Run the Ansible playbook for local configuration:
   ```bash
   ~/.pyenv/versions/ansible-env-epam/bin/ansible-playbook -i ansible/inventory/local ansible/playbooks/local_setup.yml
   ```

#### Automated Deployment Script

Alternatively, you can use the automated script to run the complete local deployment:

```bash
./scripts/local_complete_deploy.sh
```

This script will:
- Check all prerequisites
- Run Terraform initialization, plan, and apply
- Execute the Ansible playbook for configuration
- Show the deployment status

### Clean Up

To destroy the local deployment:
```bash
cd terraform
terraform destroy
```

## GitHub Actions Pipeline

The project includes a CI/CD pipeline implemented using GitHub Actions with the following workflows:

- **Local Development Test**: Validates Terraform configuration and tests Ansible playbooks
- **QA Environment Deployment**: Deploys to QA environment
- **Production Environment Deployment**: Deploys to Production environment (with manual approval)

Workflow files are located in `.github/workflows/` directory.

## Next Steps

1. Choose your cloud provider (AWS, Azure, or GCP) based on project requirements
2. Set up authentication and authorization for your chosen provider
3. Define your Terraform configuration files for the network infrastructure
4. Create Ansible playbooks for configuration management
5. Set up remote state storage for team collaboration
6. Implement the three-tier architecture (frontend, backend, database)
7. Set up GitHub Actions CI/CD pipeline
8. Set up monitoring and alerting

For more information about best practices for your chosen cloud provider:
- AWS: https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html
- Azure: https://learn.microsoft.com/en-us/azure/well-architected/
- GCP: https://cloud.google.com/architecture/framework