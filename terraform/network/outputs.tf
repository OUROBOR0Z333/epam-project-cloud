output "vpc_id" {
  description = "VPC network ID"
  value       = google_compute_network.custom_vpc.id
}

output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.custom_vpc.name
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = google_compute_subnetwork.public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = google_compute_subnetwork.private_subnet.id
}

output "router_name" {
  description = "Router name for NAT"
  value       = google_compute_router.router.name
}

output "sql_psc_connection_ready" {
  description = "Whether the SQL private service connection is ready"
  value       = google_service_networking_connection.sql_psc
}