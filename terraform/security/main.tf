# Firewall rule to allow SSH from internet to bastion host
resource "google_compute_firewall" "ssh_from_internet" {
  name    = "allow-ssh-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion-${terraform.workspace}"]
}

# Firewall rule to allow HTTP/HTTPS from internet to load balancer
resource "google_compute_firewall" "http_https_from_internet" {
  name    = "allow-http-https-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["load-balancer-${terraform.workspace}"]
}

# Firewall rule to allow all traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["app-${terraform.workspace}"]
}

# Firewall rule to allow traffic from load balancer to backend
resource "google_compute_firewall" "allow_lb_to_backend" {
  name    = "allow-lb-to-backend-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3000"]  # Backend API port
  }

  source_tags = ["load-balancer-${terraform.workspace}"]
  target_tags = ["backend-${terraform.workspace}"]
}

# Firewall rule to allow bastion host to connect to private instances
resource "google_compute_firewall" "allow_bastion_to_private" {
  name    = "allow-bastion-to-private-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "3000", "3030"]  # SSH, HTTP, API, Frontend
  }

  source_tags = ["bastion-${terraform.workspace}"]
  target_tags = ["app-${terraform.workspace}"]
}

# Firewall rule to allow egress from private subnet to internet (for dependency installation)
resource "google_compute_firewall" "allow_private_egress" {
  name    = "allow-private-egress-${terraform.workspace}"
  network = var.vpc_id
  project = var.project_id

  direction     = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags   = ["app-${terraform.workspace}"]

  allow {
    protocol = "tcp"
    ports    = ["443", "80", "53"]  # HTTPS, HTTP, DNS
  }

  allow {
    protocol = "udp"
    ports    = ["53"]  # DNS
  }
}

output "firewall_rules" {
  description = "Created firewall rules"
  value = [
    google_compute_firewall.ssh_from_internet.name,
    google_compute_firewall.http_https_from_internet.name,
    google_compute_firewall.allow_internal.name,
    google_compute_firewall.allow_lb_to_backend.name,
    google_compute_firewall.allow_bastion_to_private.name,
    google_compute_firewall.allow_private_egress.name
  ]
}