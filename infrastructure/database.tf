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

resource "google_sql_database" "appdb" {
  name     = "appdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "dbuser" {
  name     = "dbuser"
  instance = google_sql_database_instance.postgres.name
  password = "dbpassword"
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "google_secret_manager_secret" "db_pass_secret" {
  secret_id = "toptal-db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_pass_version" {
  secret      = google_secret_manager_secret.db_pass_secret.id
  secret_data = random_password.db_password.result
}

resource "google_sql_database" "appdb" {
  name     = "appdb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "dbuser" {
  name     = "dbuser"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

resource "google_sql_database_instance" "postgres" {
  # ... existing config ...
  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled                        = true
      start_time                     = "02:00" # Runs daily at 2 AM UTC
      transaction_log_retention_days = 7
    }
  }
}