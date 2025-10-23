# Basic variables for the Terraform configuration

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