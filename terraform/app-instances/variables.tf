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

variable "private_subnet" {
  description = "Private subnet where application instances will be deployed"
  type        = string
}

variable "frontend_machine_type" {
  description = "Machine type for frontend instance"
  type        = string
  default     = "e2-micro"  # Free tier eligible
}

variable "backend_machine_type" {
  description = "Machine type for backend instance"
  type        = string
  default     = "e2-micro"  # Free tier eligible
}

variable "database_host" {
  description = "Database host address"
  type        = string
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_user" {
  description = "Database username"
  type        = string
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "backend_url" {
  description = "Backend URL for frontend to connect to"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (used for resource naming)"
  type        = string
  default     = "dev"
}