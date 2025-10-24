# HTTP Health Check
resource "google_compute_http_health_check" "default" {
  name                = "http-health-check-${terraform.workspace}"
  request_path        = "/"
  check_interval_sec  = 5
  timeout_sec         = 2
  unhealthy_threshold = 3
  healthy_threshold   = 2
}

# Backend service
resource "google_compute_backend_service" "default" {
  name                  = "backend-service-${terraform.workspace}"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  health_checks         = [google_compute_http_health_check.default.self_link]
  backend {
    group = var.backend_instance_group
  }
}

# URL Map
resource "google_compute_url_map" "default" {
  name            = "url-map-${terraform.workspace}"
  default_service = google_compute_backend_service.default.self_link
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy-${terraform.workspace}"
  url_map = google_compute_url_map.default.self_link
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "default" {
  name       = "global-rule-${terraform.workspace}"
  target     = google_compute_target_http_proxy.default.self_link
  port_range = "80"
}

output "load_balancer_name" {
  description = "Name of the load balancer components"
  value = {
    health_check     = google_compute_http_health_check.default.name
    backend_service  = google_compute_backend_service.default.name
    url_map          = google_compute_url_map.default.name
    http_proxy       = google_compute_target_http_proxy.default.name
    forwarding_rule  = google_compute_global_forwarding_rule.default.name
  }
}

output "load_balancer_external_ip" {
  description = "External IP of the load balancer"
  value       = google_compute_global_forwarding_rule.default.ip_address
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${google_compute_global_forwarding_rule.default.ip_address}"
}