# Instance template for frontend
resource "google_compute_instance_template" "frontend" {
  name         = "frontend-template-${terraform.workspace}"
  machine_type = var.frontend_machine_type

  tags = ["frontend-${terraform.workspace}", "app-${terraform.workspace}"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  network_interface {
    subnetwork = var.private_subnet
    # Access to internet via NAT gateway (no public IP)
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = google_service_account.app_instances.email
    scopes = ["cloud-platform"]
  }

  # Startup script to install basic requirements
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nodejs npm git curl
    # Environment variables will be set by Ansible
    echo "Frontend instance setup complete"
  EOF
}

# Instance group manager for frontend (needed for load balancer)
resource "google_compute_instance_group_manager" "frontend" {
  name = "frontend-group-${terraform.workspace}"
  zone = var.zone

  version {
    instance_template = google_compute_instance_template.frontend.self_link
    name              = "primary"
  }

  base_instance_name = "frontend-${terraform.workspace}"
  target_size        = 1  # Start with 1 instance, can be scaled
}

# Backend VM instance (standalone, not in instance group)
resource "google_compute_instance" "backend" {
  name         = "backend-${terraform.workspace}"
  machine_type = var.backend_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["backend-${terraform.workspace}", "app-${terraform.workspace}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = var.private_subnet
    # Access to internet via NAT gateway (no public IP)
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = google_service_account.app_instances.email
    scopes = ["cloud-platform"]
  }

  # Startup script to install basic requirements
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nodejs npm git curl
    # Environment variables will be set by Ansible
    echo "Backend instance setup complete"
  EOF
}

# Shared service account for app instances
resource "google_service_account" "app_instances" {
  account_id   = "app-sa-${terraform.workspace}"
  display_name = "App Service Account for ${terraform.workspace}"
  project      = var.project_id
}

# IAM binding for the service account
resource "google_project_iam_member" "app_instances" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.app_instances.email}"
}

output "frontend_instance_template" {
  description = "Frontend instance template self-link"
  value       = google_compute_instance_template.frontend.self_link
}

output "frontend_instance_group" {
  description = "Frontend instance group self-link"
  value       = google_compute_instance_group_manager.frontend.instance_group
}

output "frontend_instance_group_name" {
  description = "Name of the frontend instance group manager"
  value       = google_compute_instance_group_manager.frontend.name
}

output "backend_instance_name" {
  description = "Name of the backend instance"
  value       = google_compute_instance.backend.name
}

output "backend_internal_ip" {
  description = "Internal IP of the backend instance"
  value       = google_compute_instance.backend.network_interface.0.network_ip
}

output "app_service_account" {
  description = "Service account email for app instances"
  value       = google_service_account.app_instances.email
}