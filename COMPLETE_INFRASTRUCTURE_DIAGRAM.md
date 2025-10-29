# Complete Infrastructure with Terraform State Management Diagram

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                          COMPLETE INFRASTRUCTURE TOPOLOGY                          │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                        GOOGLE CLOUD PLATFORM (GCP)                          │  │
│  │                    Project: epamgcpdeployment2                             │  │
│  │                                                                             │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐│  │
│  │  │                      VPC NETWORK                                        ││  │
│  │  │               movie-analyst-vpc-qa                                    ││  │
│  │  │                                                                         ││  │
│  │  │  PUBLIC SUBNET (10.0.1.0/24)                                            ││  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐││  │
│  │  │  │  Bastion VM                                                     │││  │
│  │  │  │  bastion-qa                                                    │││  │
│  │  │  │  External IP: 34.61.107.53                                         │││  │
│  │  │  │  Internal IP: 10.0.1.2                                             │││  │
│  │  │  │  Role: Secure SSH access to private instances                     │││  │
│  │  │  │  Tags: bastion-default                                             │││  │
│  │  │  │  Service Account: bastion-sa-default@...                           │││  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘││  │
│  │  │                                                                         ││  │
│  │  │  PRIVATE SUBNET (10.0.2.0/24)                                          ││  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐││  │
│  │  │  │  Backend VM                                                     │││  │
│  │  │  │  backend-qa                                                     │││  │
│  │  │  │  Internal IP: 10.0.2.2                                             │││  │
│  │  │  │  Role: Backend API service (Node.js/Express)                      │││  │
│  │  │  │  Tags: backend-default, app-default                               │││  │
│  │  │  │  Service Account: app-sa-default@...                              │││  │
│  │  │  │  Services:                                                         │││  │
│  │  │  │    - Cloud SQL Proxy (localhost:3306)                             │││  │
│  │  │  │    - Backend API (port 3000)                                      │││  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘││  │
│  │  │                                                                         ││  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐││  │
│  │  │  │  Frontend VM                                                    │││  │
│  │  │  │  frontend-qa-vpr8                                               │││  │
│  │  │  │  Internal IP: 10.0.2.3                                             │││  │
│  │  │  │  Role: Frontend web service (Node.js/Express)                      │││  │
│  │  │  │  Tags: frontend-default, app-default                              │││  │
│  │  │  │  Service Account: app-sa-default@...                              │││  │
│  │  │  │  Services:                                                         │││  │
│  │  │  │    - Frontend Web UI (port 3030)                                   │││  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘││  │
│  │  │                                                                         ││  │
│  │  │  DATABASE SUBNET (10.3.30.0/24)                                        ││  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐││  │
│  │  │  │  Cloud SQL Database                                              │││  │
│  │  │  │  movie-db-qa                                                    │││  │
│  │  │  │  Private IP: 10.3.30.5                                             │││  │
│  │  │  │  Role: MySQL 8.0 database                                        │││  │
│  │  │  │  Database: movie_db                                               │││  │
│  │  │  │  User: app_user                                                  │││  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘││  │
│  │  │                                                                         ││  │
│  │  │  LOAD BALANCER                                                         ││  │
│  │  │  Global External IP: 34.107.139.237                                   ││  │
│  │  │  Target: frontend-qa-vpr8 (port 3030)                                 ││  │
│  │  └─────────────────────────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                    FIREWALL RULES                                               ││
│  │  - Allow SSH from Internet (bastion-default: port 22)                         ││
│  │  - Allow HTTP/HTTPS from Internet (load-balancer-default: ports 80,443)        ││
│  │  - Allow Internal Communication (app-default: ports 0-65535 TCP/UDP)          ││
│  │  - Allow Bastion to Private (bastion-default → app-default: ports 22,80,443,3000,3030)││
│  │  - Allow Load Balancer to Backend (load-balancer-default → backend-default: port 3000)││
│  │  - Allow Private Egress (app-default: ports 443,80,53 TCP/UDP)               ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
└──────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│                        TERRAFORM STATE MANAGEMENT                                   │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────┐  │
│  │                    GITHUB REPOSITORY                                        │  │
│  │              OUROBOR0Z333/epam-project-cloud                             │  │
│  │                                                                             │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐│  │
│  │  │                    GITHUB ACTIONS                                       ││  │
│  │  │                    Workflows                                              ││  │
│  │  │  Foundation (1.x) → Infrastructure (2.x) → Application (3.x) → Monitor (4.x)││  │
│  │  └─────────────────────────────────────────────────────────────────────────┘│  │
│  │                                                                             │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐│  │
│  │  │                    TERRAFORM CONFIGURATION                              ││  │
│  │  │  Local Files:                                                             ││  │
│  │  │    - terraform/                                                           ││  │
│  │  │    - backend.tf (references GCS bucket)                                   ││  │
│  │  │    - main.tf, variables.tf, outputs.tf                                  ││  │
│  │  │    - modules/ (network, security, database, etc.)                       ││  │
│  │  └─────────────────────────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │                       GOOGLE CLOUD STORAGE                                    ││
│  │                    TERRAFORM STATE BUCKET                                      ││
│  │                                                                             │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────┐│  │
│  │  │  Bucket Name: epam-bucket-gcp2025                                        ││  │
│  │  │  Location: gs://epam-bucket-gcp2025/                                   ││  │
│  │  │                                                                         ││  │
│  │  │  ┌─────────────────────────────────────────────────────────────────────┐││  │
│  │  │  │  Terraform State Directory                                         │││  │
│  │  │  │  Path: terraform/state/                                            │││  │
│  │  │  │                                                                     │││  │
│  │  │  │  State Files:                                                       │││  │
│  │  │  │    - default.tfstate                                               │││  │
│  │  │  │    - qa.tfstate                                                     │││  │
│  │  │  │    - prod.tfstate                                                   │││  │
│  │  │  │    - qa/ (workspace directory)                                     │││  │
│  │  │  │    - terraform/ (workspace directory)                               │││  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘││  │
│  │  │                                                                         ││  │
│  │  │  Purpose:                                                                ││  │
│  │  │    - Persistent state storage                                           ││  │
│  │  │    - State locking to prevent conflicts                                 ││  │
│  │  │    - Collaboration between team members                                 ││  │
│  │  │    - Backup and recovery                                                ││  │
│  │  │    - Remote state access for workflows                                 ││  │
│  │  └─────────────────────────────────────────────────────────────────────────┘│  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│                        DATA FLOW & RELATIONSHIPS                                   │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  GitHub Actions Workflows                                                           │
│          ↓                                                                         │
│  Terraform Configuration (Local)                                                  │
│          ↓                                                                         │
│  Terraform Backend (backend.tf)                                                    │
│          ↓                                                                         │
│  GCS Bucket: epam-bucket-gcp2025                                                   │
│          ↓                                                                         │
│  Google Cloud Platform (GCP)                                                      │
│          ↓                                                                         │
│  Infrastructure Components                                                         │
│    - VPC Network                                                                   │
│    - Compute Instances (VMs)                                                      │
│    - Cloud SQL Database                                                            │
│    - Load Balancer                                                                 │
│    - Firewall Rules                                                                │
│                                                                                    │
│  Ansible Configuration Management                                                 │
│          ↓                                                                         │
│  Application Deployment                                                            │
│          ↓                                                                         │
│  Monitoring & Health Checks                                                         │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│                             SECURITY MODEL                                          │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  Service Accounts:                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │ bastion-sa-default@epamgcpdeployment2.iam.gserviceaccount.com                 ││
│  │   - Used by: Bastion VM                                                         ││
│  │   - Permissions: Editor role for project management                           ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐│
│  │ app-sa-default@epamgcpdeployment2.iam.gserviceaccount.com                     ││
│  │   - Used by: Backend VM, Frontend VM                                           ││
│  │   - Permissions: Compute Instance access, OS Login                             ││
│  └─────────────────────────────────────────────────────────────────────────────────┘│
│                                                                                    │
│  Network Security:                                                                  │
│  - Private subnets isolate application components                                │
│  - Bastion host provides secure access to private instances                        │
│  - Firewall rules restrict traffic to necessary ports only                        │
│  - Load balancer provides single entry point for external traffic                 │
│  - Cloud SQL uses private IP and is accessible only through Cloud SQL Proxy        │
│                                                                                    │
│  Data Security:                                                                     │
│  - Database credentials stored in GitHub Secrets                                   │
│  - Cloud SQL Proxy provides encrypted tunnel to database                          │
│  - HTTPS encryption for web traffic                                                │
│  - OS Login for SSH access with temporary keys                                     │
└────────────────────────────────────────────────────────────────────────────────────┘

Legend:
──────  Component Relationships
══════  Data Flow
......  Network Connections
```