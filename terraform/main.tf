# Main Terraform configuration that calls all modules
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Network module
module "network" {
  source       = "./network"
  project_id   = var.project_id
  region       = var.region
}

# Security module
module "security" {
  source       = "./security"
  project_id   = var.project_id
  vpc_id       = module.network.vpc_id
}

# Bastion module
module "bastion" {
  source         = "./bastion"
  project_id     = var.project_id
  region         = var.region
  zone           = var.zone
  public_subnet  = module.network.public_subnet_id
  ssh_allowed_ips = var.ssh_allowed_ips
}

# Database module
module "database" {
  source            = "./database"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  vpc_network_id    = module.network.vpc_id
  db_tier           = "db-f1-micro"  # Free-tier eligible for both environments
  db_root_password  = var.db_root_password
}

# App Instances module
module "app_instances" {
  source            = "./app-instances"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  private_subnet    = module.network.private_subnet_id
  database_host     = module.database.database_connection_name
  database_name     = module.database.database_name
  database_user     = module.database.database_user
  database_password = module.database.database_password
  backend_url       = "backend-${terraform.workspace}.internal:3000"  # Internal communication
}

# Load Balancer module
module "load_balancer" {
  source               = "./load-balancer"
  project_id           = var.project_id
  region               = var.region
  backend_instance_group = module.app_instances.frontend_instance_group
}