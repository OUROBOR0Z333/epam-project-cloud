# VPC Network
resource "google_compute_network" "custom_vpc" {
  name                    = "movie-analyst-vpc-${terraform.workspace}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Public Subnet (for load balancer, bastion host, NAT)
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet-${terraform.workspace}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  project       = var.project_id
}

# Private Subnet (for application VMs and database)
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet-${terraform.workspace}"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  project       = var.project_id
}

# Router for NAT
resource "google_compute_router" "router" {
  name    = "router-${terraform.workspace}"
  region  = var.region
  network = google_compute_network.custom_vpc.name
  project = var.project_id
}

# Cloud NAT for private subnet internet access
resource "google_compute_router_nat" "nat" {
  name   = "nat-gateway-${terraform.workspace}"
  router = google_compute_router.router.name
  region = var.region
  project = var.project_id

  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Allow ICMP, TCP, UDP
  icmp_idle_timeout_sec = 30
  tcp_established_idle_timeout_sec = 1200
  tcp_transitory_idle_timeout_sec = 30
  udp_idle_timeout_sec = 30
}

# Internet Gateway (automatically created with VPC)
# Route table configuration (default routes included with VPC)

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = google_compute_network.custom_vpc.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = google_compute_subnetwork.public_subnet.id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = google_compute_subnetwork.private_subnet.id
}

output "public_subnet_name" {
  description = "Public Subnet Name"
  value       = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_name" {
  description = "Private Subnet Name"
  value       = google_compute_subnetwork.private_subnet.name
}

output "router_name" {
  description = "Router name for NAT"
  value       = google_compute_router.router.name
}