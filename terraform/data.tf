# -----------------------------------------------------------------
# data.tf  – one place that decides "latest Ubuntu 20.04"
# -----------------------------------------------------------------
data "google_compute_image" "ubuntu_2004" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

# Since Ubuntu 20.04 is deprecated, let's also add Ubuntu 22.04 as fallback
data "google_compute_image" "ubuntu_2204" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}