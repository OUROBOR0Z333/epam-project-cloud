variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
  default     = "epamgcpdeployment2"
}

variable "bucket_name" {
  description = "Name for the first bucket"
  type        = string
  default     = "tf-bucket-epgcp"
}

variable "region" {
  description = "The region for the bucket"
  type        = string
  default     = "US-CENTRAL1"
}

variable "location" {
  description = "The location where the bucket will be created"
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "The storage class for the bucket"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Force destruction of the bucket and its contents"
  type        = bool
  default     = false
}

variable "credentials_path" {
  description = "Path to the service account key file"
  type        = string
  default     = "/home/ouroboroz/terraform-key.json"
}

variable "backend_prefix" {
  description = "Prefix to use for Terraform state files in the bucket"
  type        = string
  default     = "terraform/state"
}
