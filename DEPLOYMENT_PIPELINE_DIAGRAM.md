# Deployment Pipeline Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│                             GitHub Actions Workflows                              │
│                        (Orchestrated Deployment Pipeline)                           │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│  FOUNDATION WORKFLOWS (1.x Series) - Environment Setup & Validation               │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 1.1 Foundation – Basic Test     │    │ 1.2 Foundation – GCP Test            │   │
│  │ • Verify GitHub Actions        │    │ • Test GCP connectivity              │   │
│  │ • Check basic functionality     │    │ • Validate GCP authentication        │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 1.3 Foundation – Terraform GCP │    │ 1.4 Foundation – Test GCP Auth       │   │
│  │ • Validate Terraform configs   │    │ • Deep authentication testing        │   │
│  │ • Test GCP provider             │    │ • Verify service account perms      │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 1.5 Foundation – Create Bucket │   │ 1.6 Foundation – Delete Bucket      │   │
│  │ • Create GCS bucket for state   │    │ • Delete GCS bucket (cleanup)         │   │
│  │ • Set up versioning            │    │ • Remove all objects                 │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
│                                                                                    │
│  ┌─────────────────────────────────┐                                               │
│  │ 1.7 Foundation – Configure      │                                               │
│  │   Terraform Backend             │                                               │
│  │ • Update backend.tf             │                                               │
│  │ • Configure GCS backend        │                                               │
│  │ • Initialize Terraform          │                                               │
│  └─────────────────────────────────┘                                               │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│  INFRASTRUCTURE DEPLOYMENT (2.x Series) - Core Infrastructure Provisioning       │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 2.2 Infrastructure – Complete   │    │ 2.2 Infrastructure – Complete         │   │
│  │   Deployment                    │    │   Deployment Secure                  │   │
│  │ • Full infrastructure deploy   │    │ • Secure workspace deployment        │   │
│  │ • VPC, subnets, routing         │    │ • Workspace isolation                │   │
│  │ • Security groups & firewalls   │    │ • Auto-approval protection           │   │
│  │ • Compute instances            │    │ • Manual approval option             │   │
│  │ • Cloud SQL database            │    │ • Environment selection             │   │
│  │ • Load balancer setup           │    │                                      │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│  APPLICATION DEPLOYMENT (3.x Series) - Application & Database Configuration        │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 3.8.5 Database – Schema         │    │ 3.9 Application – Deploy to         │   │
│  │   Initialization                │    │   Infrastructure                     │   │
│  │ • Initialize database schema    │    │ • Deploy application code            │   │
│  │ • Create tables & indexes       │    │ • Install dependencies               │   │
│  │ • Populate initial data         │    │ • Configure services                 │   │
│  │ • Set up database users          │    │ • Start application processes        │   │
│  │ • Run seeds.js script           │    │ • Configure environment vars         │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 3.9 Infrastructure –           │    │                                      │   │
│  │   Configuration Validation       │    │                                      │   │
│  │ • Validate Terraform configs   │    │                                      │   │
│  │ • Check Ansible playbooks       │    │                                      │   │
│  │ • Dry-run deployment plans      │    │                                      │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│  MONITORING & HEALTH CHECKS (4.x Series) - Ongoing System Verification             │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  ┌─────────────────────────────────┐    ┌──────────────────────────────────────┐   │
│  │ 4.0 Application – Health Check   │   │ 4.1 Database – Health Check          │   │
│  │ • Verify application status     │    │ • Check database connectivity        │   │
│  │ • Test API endpoints            │    │ • Validate database performance      │   │
│  │ • Monitor service availability  │    │ • Verify schema integrity            │   │
│  │ • Manual trigger only           │    │ • Manual trigger only                │   │
│  └─────────────────────────────────┘    └──────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│                              EXECUTION FLOW                                       │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  Foundation Workflows (1.x)                                                        │
│          ↓                                                                         │
│  Infrastructure Deployment (2.x)                                                  │
│          ↓                                                                         │
│  Application Deployment (3.x)                                                      │
│          ↓                                                                         │
│  Monitoring & Health Checks (4.x)                                                   │
│                                                                                    │
│  Manual Triggers Only (No Scheduled/Cron Jobs)                                    │
└────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW                                               │
├────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                    │
│  GitHub Repository                                                                 │
│          ↓                                                                         │
│  GitHub Actions (Orchestration)                                                    │
│          ↓                                                                         │
│  Terraform (IaC)                                                                   │
│          ↓                                                                         │
│  Google Cloud Platform (GCP)                                                       │
│          ↓                                                                         │
│  Infrastructure Components                                                         │
│          ↓                                                                         │
│  Ansible (Configuration Management)                                                │
│          ↓                                                                         │
│  Application Deployment                                                            │
└────────────────────────────────────────────────────────────────────────────────────┘

Legend:
──────  Workflow Dependencies
══════  Data Flow
......  Manual Trigger Points
```