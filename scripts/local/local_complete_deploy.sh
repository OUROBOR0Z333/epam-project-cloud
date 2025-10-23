#!/bin/bash

# Complete Local Deployment Workflow Script for EPAM Cloud Project

set -e  # Exit on any error

echo "========================================="
echo "EPAM Cloud Project - Complete Local Deployment Workflow"
echo "========================================="

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        echo "Terraform is not installed. Please install it first."
        echo "You can use tfenv to manage Terraform versions:"
        echo "  tfenv install 1.9.5"
        echo "  tfenv use 1.9.5"
        exit 1
    fi

    # Check if Ansible is available in the expected environment
    if [ ! -f "$HOME/.pyenv/versions/ansible-env-epam/bin/ansible-playbook" ]; then
        echo "Ansible is not available in the expected environment."
        echo "Please ensure your Ansible environment is set up correctly."
        exit 1
    fi
    
    echo "✓ All prerequisites met"
}

# Function to run Terraform deployment
run_terraform() {
    echo
    echo "=== Running Terraform Deployment ==="
    cd terraform
    
    echo "Initializing Terraform..."
    terraform init
    
    echo "Planning Terraform configuration..."
    terraform plan
    
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    echo "✓ Terraform deployment completed"
    cd ..
}

# Function to run Ansible configuration
run_ansible() {
    echo
    echo "=== Running Ansible Configuration ==="
    
    ANSIBLE_STDOUT_CALLBACK=debug ~/.pyenv/versions/ansible-env-epam/bin/ansible-playbook \
        -i ansible/inventory/local \
        ansible/playbooks/local_complete_deploy.yml
    
    echo "✓ Ansible configuration completed"
}

# Function to show deployment status
show_status() {
    echo
    echo "=== Deployment Status ==="
    echo "Terraform state file: $(ls -la terraform/terraform.tfstate 2>/dev/null || echo 'Not found')"
    echo "Terraform deployment log: $(cat terraform/local_deployment.log 2>/dev/null || echo 'Not found')"
    echo "Ansible deployment directory: $(ls -la /tmp/Epam_Cloud_Project_local/ 2>/dev/null || echo 'Not found')"
    
    if [ -f "/tmp/Epam_Cloud_Project_local/deployment_marker.txt" ]; then
        echo "Deployment marker content:"
        cat /tmp/Epam_Cloud_Project_local/deployment_marker.txt
    fi
    
    echo
    echo "========================================="
    echo "Local deployment simulation completed successfully!"
    echo "========================================="
}

# Main execution
main() {
    check_prerequisites
    run_terraform
    run_ansible
    show_status
}

# Run the main function
main "$@"