# Basic outputs for the Terraform configuration

output "hello_world_output" {
  description = "A simple hello world output"
  value       = "Hello World! Terraform is working correctly."
}

output "project_id" {
  description = "The project ID being used"
  value       = var.project_id
}

# Bastion outputs
output "bastion_instance_name" {
  description = "Name of the bastion instance"
  value       = module.bastion.bastion_instance_name
}

output "bastion_external_ip" {
  description = "External IP of the bastion instance"
  value       = module.bastion.bastion_external_ip
}

output "bastion_internal_ip" {
  description = "Internal IP of the bastion instance"
  value       = module.bastion.bastion_internal_ip
}

output "bastion_service_account" {
  description = "Service account email for bastion"
  value       = module.bastion.bastion_service_account
}

# Database outputs
output "database_connection_name" {
  description = "Connection name for the database"
  value       = module.database.database_connection_name
}

output "database_name" {
  description = "Name of the database"
  value       = module.database.database_name
}

output "database_user" {
  description = "User for the database"
  value       = module.database.database_user
  sensitive   = true
}

output "database_password" {
  description = "Password for the database"
  value       = module.database.database_password
  sensitive   = true
}

# App Instances outputs
output "backend_instance_name" {
  description = "Name of the backend instance"
  value       = module.app_instances.backend_instance_name
}

output "backend_internal_ip" {
  description = "Internal IP of the backend instance"
  value       = module.app_instances.backend_internal_ip
}

output "app_service_account" {
  description = "Service account for app instances"
  value       = module.app_instances.app_service_account
}

output "frontend_instance_group" {
  description = "Frontend instance group"
  value       = module.app_instances.frontend_instance_group
}

# Load Balancer outputs
output "load_balancer_external_ip" {
  description = "External IP of the load balancer"
  value       = module.load_balancer.load_balancer_external_ip
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = module.load_balancer.load_balancer_url
}