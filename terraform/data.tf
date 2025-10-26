# -----------------------------------------------------------------
# data.tf  – one place that decides "latest Ubuntu 22.04"
# -----------------------------------------------------------------
# Ubuntu 20.04 LTS is deprecated, so we use Ubuntu 22.04 LTS
data "google_compute_image" "ubuntu_2204" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}