# Local to determine machine type based on workspace
locals {
  bastion_machine_type = terraform.workspace == "prod" ? "e2-medium" : "e2-micro"  # Smaller for QA
}

# Compute instance for bastion host
resource "google_compute_instance" "bastion" {
  name         = "bastion-${terraform.workspace}"
  machine_type = local.bastion_machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["bastion-${terraform.workspace}", "app-${terraform.workspace}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 10
    }
  }

  network_interface {
    network    = var.public_subnet
    subnetwork = var.public_subnet

    access_config {
      # Ephemeral IP
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
}

# Service account for bastion host
resource "google_service_account" "bastion" {
  account_id   = "bastion-sa-${terraform.workspace}"
  display_name = "Bastion Service Account for ${terraform.workspace}"
  project      = var.project_id
}

# IAM binding for the service account
resource "google_project_iam_member" "bastion" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

output "bastion_instance_name" {
  description = "Name of the bastion instance"
  value       = google_compute_instance.bastion.name
}

output "bastion_external_ip" {
  description = "External IP of the bastion instance"
  value       = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}

output "bastion_internal_ip" {
  description = "Internal IP of the bastion instance"
  value       = google_compute_instance.bastion.network_interface.0.network_ip
}

output "bastion_service_account" {
  description = "Service account email for bastion"
  value       = google_service_account.bastion.email
}