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

variable "backend_instance_group" {
  description = "Backend instance group self link"
  type        = string
}

variable "frontend_port" {
  description = "Port for the frontend service"
  type        = number
  default     = 3030
}