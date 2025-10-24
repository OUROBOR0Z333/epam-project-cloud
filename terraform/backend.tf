# Backend configuration for Terraform state management
# This will be updated by the configure-backend workflow to use GCS in production

# By default, use local backend for testing
# The configure-backend workflow will modify this for production deployments
terraform {
  # backend "gcs" {
  #   bucket = "epam-bucket-gcp2025"
  #   prefix = "terraform/state"
  # }
  backend "local" {}
}