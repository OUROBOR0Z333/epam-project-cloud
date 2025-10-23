variable "bucket_name" {
  description = "The name of the storage bucket"
  type        = string
  default     = "tf-bucket"
}

variable "location" {
  description = "The location where the bucket will be created"
  type        = string
  default     = "US"
}

variable "project_id" {
  description = "The ID of the project where the bucket will be created"
  type        = string
}

variable "storage_class" {
  description = "The storage class for the bucket"
  type        = string
  default     = "STANDARD"
}

variable "force_destroy" {
  description = "Force the deletion of the bucket and all its contents"
  type        = bool
  default     = false
}