resource "google_compute_region_network_endpoint_group" "web_neg" {
  name                  = "web-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.web.name
  }
}

resource "google_compute_backend_service" "web_backend" {
  name       = "web-backend"
  enable_cdn = true
  backend {
    group = google_compute_region_network_endpoint_group.web_neg.id
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "frontend_rule" {
  name       = "web-frontend-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}