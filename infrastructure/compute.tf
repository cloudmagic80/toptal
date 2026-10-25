# Serverless VPC Access Connector for private database communication
resource "google_vpc_access_connector" "connector" {
  name          = "toptal-connector"
  region        = "us-central1"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
  min_instances = 2
  max_instances = 3
}

# API Tier
resource "google_cloud_run_v2_service" "api" {
  name     = "toptal-api"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL" # Changed from INTERNAL_ONLY

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Overwritten by CI/CD
      
      env {
        name  = "DBHOST"
        value = google_sql_database_instance.postgres.private_ip_address
      }
      env {
        name  = "DBUSER"
        value = "dbuser" # Best practice: move to GCP Secret Manager later
      }
      env {
        name = "DBPASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_pass_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "DB"
        value = "appdb"
      }
      env {
        name  = "DBPORT"
        value = "5432"
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "ALL_TRAFFIC"
    }
  }
}

# Web Tier
resource "google_cloud_run_v2_service" "web" {
  name     = "toptal-web"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Overwritten by CI/CD
      
      env {
        name  = "API_HOST"
        value = google_cloud_run_v2_service.api.uri
      }
    }
  }
}

# Allow public internet access to the Web tier
resource "google_cloud_run_service_iam_member" "web_public" {
  location = google_cloud_run_v2_service.web.location
  project  = google_cloud_run_v2_service.web.project
  service  = google_cloud_run_v2_service.web.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow public internet access to the API tier
resource "google_cloud_run_service_iam_member" "api_public" {
  location = google_cloud_run_v2_service.api.location
  project  = google_cloud_run_v2_service.api.project
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}