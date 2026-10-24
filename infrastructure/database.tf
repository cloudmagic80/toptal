resource "google_sql_database_instance" "postgres" {
  name             = "toptal-db-instance"
  database_version = "POSTGRES_15"
  region           = "us-central1"
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }
  }
  deletion_protection = false
}