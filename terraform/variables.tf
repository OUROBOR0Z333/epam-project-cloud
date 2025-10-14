variable "environment" {
  description = "The environment being deployed to (qa/prod)"
  type        = string
  default     = "qa"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Epam_Cloud_Project"
}

variable "region" {
  description = "The region for deployment"
  type        = string
  default     = "local"
}

variable "instance_type" {
  description = "Type of instance to deploy"
  type        = string
  default     = "local_simulation"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "local_db"
}

variable "database_user" {
  description = "Database user"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "password123"
  sensitive   = true
}