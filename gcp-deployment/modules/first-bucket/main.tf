resource "google_storage_bucket" "first_bucket" {
  name                        = var.bucket_name
  location                    = var.location
  project                     = var.project_id
  force_destroy               = var.force_destroy
  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }
}