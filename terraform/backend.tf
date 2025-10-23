# Backend configuration for Terraform state management
# This should be configured based on your requirements

terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"  # Replace with your actual bucket name
    prefix = "terraform/state"
  }
}