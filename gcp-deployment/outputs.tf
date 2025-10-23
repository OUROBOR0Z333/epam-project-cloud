output "first_bucket_name" {
  description = "The name of the created first bucket"
  value       = module.first_bucket.bucket_name
}

output "first_bucket_url" {
  description = "The URL of the created first bucket"
  value       = module.first_bucket.bucket_url
}

output "first_bucket_self_link" {
  description = "The URI of the created first bucket"
  value       = module.first_bucket.bucket_self_link
}

output "backend_config" {
  description = "Backend configuration for Terraform"
  value       = module.backend.backend_config
}