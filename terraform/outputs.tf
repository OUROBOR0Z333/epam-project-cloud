# Basic outputs for the Terraform configuration

output "hello_world_output" {
  description = "A simple hello world output"
  value       = "Hello World! Terraform is working correctly."
}

output "project_id" {
  description = "The project ID being used"
  value       = var.project_id
}