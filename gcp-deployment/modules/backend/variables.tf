variable "bucket_name" {
  description = "The name of the bucket to use for backend storage"
  type        = string
}

variable "prefix" {
  description = "The prefix to use for state files in the bucket"
  type        = string
  default     = "terraform/state"
}