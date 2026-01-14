terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_dns_managed_zone" "main" {
  project     = var.project_id
  name        = "${var.project_shortname}-zone"
  dns_name    = "${var.project_shortname}.${var.fqdn}."
  description = "DNS zone for the OTT service"
}

# Reserve a global static IP for the Load Balancer
resource "google_compute_global_address" "gclb_ip" {
  project = var.project_id
  name    = "${var.project_shortname}-gclb-ipv4"
}

# Create an A record for the load balancer
resource "google_dns_record_set" "a_record" {
  name         = google_dns_managed_zone.main.dns_name
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

resource "google_dns_record_set" "cdn" {
  name         = "cdn.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

resource "google_dns_record_set" "stream" {
  name         = "stream.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

resource "google_dns_record_set" "origin" {
  name         = "origin.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

resource "google_dns_record_set" "ott" {
  name         = "ott.${google_dns_managed_zone.main.dns_name}"
  managed_zone = google_dns_managed_zone.main.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gclb_ip.address]
}

# Create a Google-managed SSL certificate for all domains
resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "${var.project_shortname}-zone-tls-cert"

  managed {
    domains = [
      "cdn.${google_dns_managed_zone.main.dns_name}",
      "www.${google_dns_managed_zone.main.dns_name}",
      "stream.${google_dns_managed_zone.main.dns_name}",
      "origin.${google_dns_managed_zone.main.dns_name}",
      "ott.${google_dns_managed_zone.main.dns_name}"
    ]
  }
}