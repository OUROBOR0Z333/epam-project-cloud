## Qwen Added Memories
- PDF Content: Cloud & DevOps Fundamentals – Automation Tools Practical Task. The client wants to migrate to cloud with Terraform, Ansible, and GCP. The application consists of Front-end, Back-end, and MySQL database. Requirements include: no serverless (use compute instances), managed MySQL database, private subnets for backend/db with internet egress, load balancer for backend traffic, free-tier services where possible, and bastion host for Ansible. Two environments needed: QA and Production using Terraform workspaces. All GitHub Actions workflows are in place. Application source code is at https://github.com/aljoveza/devops-rampup/tree/master
- Application Structure: The application consists of two components from the devops-rampup repository: 1) movie-analyst-api (backend) - Node.js/Express app that connects to MySQL database, exposes endpoints like /movies, /reviewers, /publications, /pending; 2) movie-analyst-ui (frontend) - Node.js/Express app using EJS templates that consumes the backend API. Database schema includes tables for publications, reviewers, and movies. Backend exposes API on port 3000, frontend serves on port 3030. Both apps use environment variables for configuration (DB_HOST, DB_USER, DB_PASS, DB_NAME for backend; BACKEND_URL for frontend).
- Current project context: Working on Epam_Cloud_Project directory with a focus on implementing cloud infrastructure using Terraform, Ansible, and GCP for a movie analyst application that consists of a frontend (movie-analyst-ui) and backend (movie-analyst-api) that connects to a MySQL database. Today's date is Saturday, October 25, 2025, and I'm on Linux.
- GitHub Actions workflows are located in /home/ouroboroz/Projects/Epam_Cloud_Project/epam-cloud-project/.github/workflows/. There are 19 workflow files that handle different stages of infrastructure deployment. The master workflow (3.3-full-master-sequential-deployment.yml) orchestrates the full deployment process including VPC, subnets, NAT gateway, firewall rules, compute instances (with bastion host), database, load balancer, and application deployment via Ansible. Infrastructure is defined in Terraform files in /epam-cloud-project/terraform/ directory, with modules for network, security, bastion, database, app instances, and load balancer. Workflows use GCP authentication and environment secrets, with Terraform workspaces for QA and Production environments.
- The 3.8-deploy-qa-workspace-fix.yml script is a GitHub Actions workflow designed to fix Terraform workspace management issues during QA environment deployments. It properly handles workspace selection/creation, creates deployment plans with required variables, offers secure deployment options (manual review or auto-approve), and includes error handling for potential lock file issues. This script was specifically created to address workspace-related problems in the main deployment process, ensuring proper TF state management between QA and production environments.
- The movie analyst application is a three-tier application consisting of: 1) Frontend (movie-analyst-ui) - Node.js/Express app with EJS templates, 2) Backend (movie-analyst-api) - Node.js/Express API that connects to the database and serves data to the frontend, 3) Database (MySQL) - Managed MySQL database storing the application data.
- Movie Analyst application deployment complete. Load balancer IP: 34.107.139.237. Frontend is accessible at http://34.107.139.237. Backend service running on 10.0.2.2:3000 but may have database connectivity issues. Both services running under PM2 process manager.
- Movie Analyst application deployment analysis: Frontend is successfully deployed and accessible at http://34.107.139.237. Backend service is running on 10.0.2.2:3000 but specific API endpoints are not responding, indicating database connectivity issues. Database exists as Cloud SQL instance but lacks schema initialization and data population. No SQL initialization scripts found in repository. Need to initialize database schema and populate with sample data for backend API to function properly.
- Known Issues / Technical Debt: 
  - 2025-10-28 – Missing Database Schema Initialisation Backend API fails (`ER_NO_SUCH_TABLE`, errno 1146) because Cloud SQL is provisioned empty and **seeds.js** (which creates tables & inserts sample data) is never executed by any layer of the pipeline.
  
  Confirmed evidence
  1. **Code** – `movie-analyst-api/seeds.js` holds `CREATE TABLE` + `INSERT` SQL.
     `server.js` assumes those tables already exist.
  2. **IaC** – `terraform/database/main.tf` only creates the Cloud SQL instance,
     database and user; no schema loading resource.
  3. **CM** – `ansible/playbooks/roles/backend/tasks/main.yml` installs Node and
     starts the app via PM2 but never runs seeds.js.
  4. **CI/CD** – No GitHub Actions workflow imports SQL or calls seeds.js.
  5. **Runtime** – `SHOW TABLES` on Cloud SQL returns empty; `/movies` endpoint
     returns 500.
  
  Remediation (short-term)
  • Separated concerns by creating two distinct Ansible playbooks:
    1. `site.yml` - Handles application deployment and Cloud SQL Proxy setup
    2. `database_init.yml` - Dedicated playbook for database schema initialization
    
  The new approach:
  • `database_init.yml` executes seeds.js in a separate step after application deployment:
  ```yaml
   - name: Run database schema initialization
     command: node seeds.js
     args:
       chdir: "{{ app_dir }}/movie-analyst-api/movie-analyst-api"
     environment:
       DB_HOST: "{{ db_host }}"
       DB_USER: "{{ db_user }}"
       DB_PASS: "{{ db_password }}"
       DB_NAME: "{{ db_name }}"
     become_user: "{{ app_user }}"
     register: schema_result
  ```  
  This provides better separation of concerns between application and database deployment.
  
  Long-term options
  • Migrate to proper migration tool (Flyway, Liquibase, Knex, etc.).
  • Terraform `null_resource` + `gcloud sql import`.
  • Dedicated "Init DB" job in GitHub Actions after Ansible.
