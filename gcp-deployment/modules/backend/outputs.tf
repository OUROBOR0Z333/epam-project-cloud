output "backend_config" {
  description = "Backend configuration for Terraform"
  value = {
    bucket = var.bucket_name
    prefix = var.prefix
  }
}