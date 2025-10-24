variable "project_id" {
  description = "The ID of the project"
  type        = string
  default     = "epamgcpdeployment2"
}

variable "vpc_id" {
  description = "VPC Network ID to apply firewall rules to"
  type        = string
}