terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_path)
}

module "first_bucket" {
  source        = "./modules/first-bucket"
  bucket_name   = var.bucket_name
  location      = var.location
  project_id    = var.project_id
  storage_class = var.storage_class
  force_destroy = var.force_destroy
}

module "backend" {
  source      = "./modules/backend"
  bucket_name = module.first_bucket.bucket_name
  prefix      = var.backend_prefix

  depends_on = [module.first_bucket]
}
