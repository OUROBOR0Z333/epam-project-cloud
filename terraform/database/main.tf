# Cloud SQL instance for MySQL
resource "google_sql_database_instance" "main" {
  name             = "movie-db-${terraform.workspace}"
  database_version = "MYSQL_8_0"
  project          = var.project_id
  region           = var.region

  settings {
    tier = var.db_tier  # db-f1-micro for QA, db-n1-standard-1 for Prod

    ip_configuration {
      # Don't assign public IP to keep database private
      ipv4_enabled = false  # Using private IP only
      # Enable private services access (requires VPC peering)
      private_network = var.vpc_network_id
    }

    backup_configuration {
      enabled = terraform.workspace == "prod" ? true : false  # Only backup prod
    }

    # Database flags specific to MySQL
    database_flags {
      name  = "sql_mode"
      value = "STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO"
    }
  }

  deletion_protection = terraform.workspace == "prod" ? true : false
}

# Create the application database
resource "google_sql_database" "app_db" {
  name     = "movie_db"
  instance = google_sql_database_instance.main.name
}

# Create the application user
resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  host     = "%"
  password = random_password.app_db_password.result
}

# Generate random password for the application user
resource "random_password" "app_db_password" {
  length  = 16
  special = true
}

output "database_instance_name" {
  description = "Name of the database instance"
  value       = google_sql_database_instance.main.name
}

output "database_connection_name" {
  description = "Connection name for the database"
  value       = google_sql_database_instance.main.connection_name
}

output "database_name" {
  description = "Name of the application database"
  value       = google_sql_database.app_db.name
}

output "database_user" {
  description = "Application database username"
  value       = google_sql_user.app_user.name
  sensitive   = true
}

output "database_password" {
  description = "Application database password"
  value       = random_password.app_db_password.result
  sensitive   = true
}