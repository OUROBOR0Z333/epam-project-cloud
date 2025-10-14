#!/bin/bash

# Local Deployment Script for EPAM Cloud Project

set -e  # Exit on any error

echo "========================================="
echo "EPAM Cloud Project - Local Deployment"
echo "========================================="

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install it first."
    echo "You can use tfenv to manage Terraform versions:"
    echo "  tfenv install 1.9.5"
    echo "  tfenv use 1.9.5"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed or activated."
    echo "Please activate the Ansible environment:"
    echo "  pyenv activate ansible-env-epam"
    exit 1
fi

echo "✓ Terraform and Ansible are available"

# Initialize Terraform
echo
echo "Initializing Terraform..."
cd terraform
terraform init
echo "✓ Terraform initialized"

# Run Terraform plan
echo
echo "Running Terraform plan..."
terraform plan
echo "✓ Terraform plan completed"

# Ask user if they want to apply
echo
read -p "Do you want to apply this configuration? (yes/no): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve
    echo "✓ Terraform configuration applied"
    
    # Run Ansible playbook
    echo
    echo "Running Ansible playbook..."
    cd ../ansible
    ~/.pyenv/versions/ansible-env-epam/bin/ansible-playbook -i inventory/local playbooks/local_complete_deploy.yml
    echo "✓ Ansible playbook executed"
    
    echo
    echo "========================================="
    echo "Local deployment completed successfully!"
    echo "Check the output in terraform/ and ansible/ directories."
    echo "========================================="
else
    echo "Terraform apply skipped."
fi

# Return to the main directory
cd ..