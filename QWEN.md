# Project Context: EPAM Cloud Project

## Project Overview
- **Project Name**: Epam_Cloud_Project
- **Location**: /home/ouroboroz/Projects/Epam_Cloud_Project
- **Date Created**: Sunday, October 12, 2025
- **Project Type**: Cloud Migration using Terraform and Ansible with CI/CD pipeline implemented via GitHub Actions

## Project Description
This project is a cloud migration initiative using Terraform and Ansible to deploy a three-tier application 
(front-end, back-end, MySQL database) on a cloud provider (AWS, Azure, or GCP). 
The team needs to follow best practices for cloud architecture while keeping costs low using free tier services.

## Application Components (from https://github.com/aljoveza/devops-rampup/tree/master)
- Front-end
- Back-end  
- MySQL database

## Client Requirements
### Architecture & Best Practices
- Infrastructure must meet best standards and practices
  - Azure: https://learn.microsoft.com/en-us/azure/well-architected/
  - GCP: https://cloud.google.com/architecture/framework
  - AWS: https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html

### Cost Management
- Must reduce costs due to economic crisis
- Open to budget resources with compelling reasons

### Environment Management
- Two environments: QA (testing) and Production (end users)
- Use Terraform Workspaces: https://developer.hashicorp.com/terraform/cli/workspaces

### Team Collaboration
- Remote work support for team members
- State management solutions:
  - Azure: https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli
  - GCP: https://cloud.google.com/docs/terraform/resource-management/store-state
  - AWS: https://aws.amazon.com/blogs/devops/best-practices-for-managing-terraform-state-files-in-aws-ci-cd-pipeline/

### Code Reusability
- Public or private modules for infrastructure
- Maintainable by team across other companies

### Configuration Management
- Implement Ansible for bastion host/jump box configuration
- Configure instances and dependencies with Ansible

### CI/CD Pipeline
- Implement CI/CD pipeline using GitHub Actions
- Automated testing, validation, and deployment workflows
- Separate workflows for QA and Production environments
- Infrastructure validation and security scanning integrated into pipeline

### Monitoring
- In-house solution using cloud provider tools (no 3rd party due to budget)
- Architectural diagram required for documentation

## Technical Requirements
- No serverless services (all components on instances)
- Database using appropriate service (AWS RDS, Azure Database for MySQL)
- Database and backend in private subnets with outgoing internet access
- Backend traffic routed through load balancer
- Free tier services only
- Bastion host for Ansible operations
- All networking components (load balancers, NAT gateways, subnets, route tables, etc.)

## Current Project Structure
```
/home/ouroboroz/Projects/Epam_Cloud_Project/
└───diagrams_images/
    └───General_diagrams.png
```

## Known Assets
- `General_diagrams.png`: Contains general architectural or design diagrams for the project
- QWEN.md: This project context document
- `.github/workflows/`: Directory for GitHub Actions workflow files

## Implementation Strategy
1. Set up Terraform with remote state storage for team collaboration
2. Create Terraform modules for infrastructure components
3. Implement two environments using workspaces (QA and Production)
4. Set up bastion host for Ansible operations
5. Deploy three-tier application (frontend, backend, database)
6. Configure networking with private/public subnets
7. Implement CI/CD pipeline using GitHub Actions
8. Implement monitoring solution
9. Document architecture with diagrams

## Cloud Provider Considerations
Based on the requirements, we need to choose between:
- AWS (with RDS for MySQL, EC2 instances, VPC networking, etc.)
- Azure (with Database for MySQL, VMs, virtual networks, etc.)
- GCP (with Cloud SQL for MySQL, Compute Engine, VPC networking, etc.)

## Next Steps
- Choose specific cloud provider to focus on
- Develop detailed Terraform modules for each component
- Set up remote state storage for team collaboration
- Create network architecture with public and private subnets
- Implement bastion host for secure access
- Set up GitHub Actions CI/CD pipeline
- Set up monitoring and alerting
- Create comprehensive architectural diagram

## Local Development Setup
### Tools Installed
- **Terraform**: Managed by tfenv (version needs to be set)
- **Ansible**: Installed in pyenv environment (ansible-env-epam)
- **Cloud CLIs**: AWS, Azure, and GCP CLIs are all installed
- **Python**: Managed by pyenv with multiple versions available
- **Terraform versions available**: 1.13.3, 1.9.5

### To set up Terraform version:
```bash
tfenv install 1.9.5
tfenv use 1.9.5
```

### To activate Ansible environment:
```bash
pyenv activate ansible-env-epam
```

### Required configuration before deployment:
1. Set up cloud provider authentication
2. Configure remote state storage for Terraform
3. Set up Terraform workspaces for QA and Production environments
4. Create Ansible playbooks for configuration management
5. Configure GitHub Actions workflows for CI/CD pipeline

### Check Tools Script
A script `check_tools.sh` has been created to verify the installation status of all required tools:
- Verifies pyenv installation and version
- Verifies tfenv installation and available Terraform versions
- Checks Ansible installation in pyenv environment
- Verifies Cloud CLI tools (AWS, Azure, GCP) are installed
- Provides activation commands for environments
- Shows current environment status

To run the script: `./check_tools.sh`

## Notes
- This is a general project adapted to each cloud as per requirements
- Architecture must follow well-architected framework guidelines
- Focus on cost optimization and best practices
- Documentation and diagrams are important deliverables
- All required tools are installed; only Terraform version needs to be set
- Ansible is available in a pyenv virtual environment
- Ready to begin infrastructure development once cloud provider is selected

## Qwen Added Memories
- The EPAM Cloud Project has been dockerized with the following structure in the dockerized-version/ directory:
- backend/: Contains Dockerfile for the Node.js API server
- frontend/: Contains Dockerfile for the Node.js UI server  
- database/: Contains Dockerfile and init.sql for MySQL database
- scripts/: Contains start_docker_app.sh, stop_docker_app.sh, and docker_helper.sh
- docker-compose.yml: Orchestrates all three services (db, backend, frontend)
- .env: Environment variables for the services
- README.md: Complete documentation for the dockerized version

The dockerized application consists of a three-tier architecture:
1. Frontend (movie-analyst-ui): Node.js application on port 3030
2. Backend (movie-analyst-api): Node.js API on port 3000  
3. Database: MySQL database on port 3306

To run: ./dockerized-version/scripts/start_docker_app.sh
To stop: ./dockerized-version/scripts/stop_docker_app.sh
- Fixed Google Cloud Storage bucket creation issue by correcting project ID mismatch in terraform.tfvars file. The Terraform configuration had an incorrect project ID ("epam-cloud-project-12345") that didn't match the actual GCP project ID ("epamgcpdeployment2"). Created diagnostic scripts to prevent similar issues in the future.
