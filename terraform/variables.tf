# Root variables for the entire infrastructure
variable "project_id" {
  description = "The ID of the project"
  type        = string
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

variable "ssh_allowed_ips" {
  description = "List of IP ranges that can SSH to the bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_root_password" {
  description = "Root password for the database"
  type        = string
  sensitive   = true
}

variable "frontend_machine_type" {
  description = "Machine type for frontend instance"
  type        = string
  default     = "e2-micro"
}

variable "backend_machine_type" {
  description = "Machine type for backend instance"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Self-link of the image each VM should boot from"
  type        = string
  default     = "" # root module sets it in locals
}