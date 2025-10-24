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

variable "public_subnet" {
  description = "Public subnet where bastion will be deployed"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "List of IP ranges that can SSH to the bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # In production, restrict this
}