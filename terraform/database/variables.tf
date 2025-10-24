variable "project_id" {
  description = "The ID of the project"
  type        = string
  default     = "epamgcpdeployment2"
}

variable "region" {
  description = "The region for GCP resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for GCP resources"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_network_id" {
  description = "VPC Network ID for private services access"
  type        = string
}

variable "db_tier" {
  description = "Database tier - different for QA vs Prod"
  type        = string
  default     = "db-f1-micro"  # Free tier eligible for QA
}

variable "db_root_password" {
  description = "Root password for the database"
  type        = string
  sensitive   = true
}