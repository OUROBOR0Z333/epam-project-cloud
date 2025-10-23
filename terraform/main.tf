# Basic Terraform configuration for Hello World demo

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "null" {}

# Simple resource that just echoes a message
resource "null_resource" "hello_world" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'Hello World from Terraform!' && echo 'Terraform is provisioning infrastructure in GCP...'"
  }
}

output "hello_message" {
  value = "Hello World! Terraform configuration is ready."
}