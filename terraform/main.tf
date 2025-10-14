terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Configure the null provider
provider "null" {}

# Create a local file to simulate deployment
resource "null_resource" "local_deployment_marker" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'Local deployment simulation at ${timestamp()}' > local_deployment.log"
  }
}

# Create application deployment marker
resource "null_resource" "app_deployment_marker" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo 'Application deployment simulation at ${timestamp()}' > app_deployment.log"
  }
}

output "local_deployment_status" {
  value = "Local deployment simulation complete. Check local_deployment.log for details."
}

output "app_deployment_status" {
  value = "Application deployment simulation complete. Check app_deployment.log for details."
}

output "app_backend_port" {
  value = "3000"
}

output "app_frontend_port" {
  value = "3030"
}

output "app_deployment_directory" {
  value = "/tmp/Epam_Cloud_Project_app/"
}