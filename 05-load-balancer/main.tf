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

# --- Remote State Data Sources ---

data "terraform_remote_state" "origin_services" {
  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = "terraform/state/01-origin-services"
  }
}

data "terraform_remote_state" "ips_and_dns" {
  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = "terraform/state/04-ips-and-dns"
  }
}

locals {
  project_shortname = data.terraform_remote_state.origin_services.outputs.project_shortname
  # Use trimsuffix to handle potential trailing dot. Result: "omega.reallycloudy.com"
  dns_name = trimsuffix(data.terraform_remote_state.ips_and_dns.outputs.managed_zone_dns_name, ".")
}

# --- Backend Buckets ---

resource "google_compute_backend_bucket" "web" {
  name        = "${local.project_shortname}-web-backend"
  bucket_name = data.terraform_remote_state.origin_services.outputs.web_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: web-backend",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]
}

resource "google_compute_backend_bucket" "default_origin" {
  name        = "${local.project_shortname}-default-origin-backend"
  bucket_name = data.terraform_remote_state.origin_services.outputs.default_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: default-origin-backend",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]
}

# 1. Live Manifests (Low TTL)
resource "google_compute_backend_bucket" "stream_live_manifests" {
  name        = "${local.project_shortname}-stream-backend-live-manifests"
  bucket_name = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: stream-backend-live-manifests",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]
  
  cdn_policy {
    cache_mode  = "FORCE_CACHE_ALL"
    default_ttl = 2
    client_ttl  = 2
    max_ttl     = 2
  }
}

# 2. Live Chunks (High TTL)
resource "google_compute_backend_bucket" "stream_live_chunks" {
  name        = "${local.project_shortname}-stream-backend-live-chunks"
  bucket_name = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: stream-backend-live-chunks",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]

  cdn_policy {
    cache_mode  = "FORCE_CACHE_ALL"
    default_ttl = 3600
    client_ttl  = 3600
    max_ttl     = 3600
  }
}

# 3. VOD Manifests (High TTL)
resource "google_compute_backend_bucket" "stream_vod_manifests" {
  name        = "${local.project_shortname}-stream-backend-vod-manifests"
  bucket_name = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: stream-backend-vod-manifests",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]

  cdn_policy {
    cache_mode  = "FORCE_CACHE_ALL"
    default_ttl = 3600
    client_ttl  = 3600
    max_ttl     = 86400
  }
}

# 4. VOD Chunks (High TTL)
resource "google_compute_backend_bucket" "stream_vod_chunks" {
  name        = "${local.project_shortname}-stream-backend-vod-chunks"
  bucket_name = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  enable_cdn  = true

  custom_response_headers = [
    "x-gcdn-status: {cdn_cache_status}",
    "x-path-match: stream-backend-vod-chunks",
    "x-gcdn-cache-id: {cdn_cache_id}",
    "x-gcdn-client-region: {client_region}",
    "x-gcdn-client-city: {client_city}",
    "x-gcdn-client-rtt-ms: {client_rtt_msec}",
    "x-gcdn-device-request-type: {device_request_type}",
    "x-gcdn-user-agent-family: {user_agent_family}"
  ]

  cdn_policy {
    cache_mode  = "FORCE_CACHE_ALL"
    default_ttl = 3600
    client_ttl  = 3600
    max_ttl     = 86400
  }
}

# --- URL Map ---

resource "google_compute_url_map" "default" {
  name            = "${local.project_shortname}-url-map"
  default_service = google_compute_backend_bucket.web.id

  # Host Rule for 'www'
  host_rule {
    hosts        = ["www.${local.dns_name}"]
    path_matcher = "web-matcher"
  }

  path_matcher {
    name            = "web-matcher"
    default_service = google_compute_backend_bucket.web.id
  }

  # Host Rule for 'stream', 'cdn', 'ott'
  host_rule {
    hosts        = [
      "stream.${local.dns_name}",
      "cdn.${local.dns_name}",
      "ott.${local.dns_name}"
    ]
    path_matcher = "stream-matcher"
  }

  path_matcher {
    name            = "stream-matcher"
    default_service = google_compute_backend_bucket.stream_live_chunks.id

    # Route Rules (ordered by priority)
    
    # 1. Live Manifests (.m3u8)
    route_rules {
      priority = 10
      match_rules {
        path_template_match = "/live/**.m3u8"
      }
      service = google_compute_backend_bucket.stream_live_manifests.id
    }

    # 2. Live Chunks (.ts)
    route_rules {
      priority = 20
      match_rules {
        path_template_match = "/live/**.ts"
      }
      service = google_compute_backend_bucket.stream_live_chunks.id
    }

    # 3. VOD Manifests (.m3u8)
    route_rules {
      priority = 30
      match_rules {
        path_template_match = "/vod/**.m3u8"
      }
      service = google_compute_backend_bucket.stream_vod_manifests.id
    }

    # 4. VOD Chunks (.ts, .mp4)
    route_rules {
      priority = 40
      match_rules {
        path_template_match = "/vod/**.ts"
      }
      service = google_compute_backend_bucket.stream_vod_chunks.id
    }
    route_rules {
      priority = 41
      match_rules {
        path_template_match = "/vod/**.mp4"
      }
      service = google_compute_backend_bucket.stream_vod_chunks.id
    }
  }

  # Host Rule for 'origin'
  host_rule {
    hosts        = ["origin.${local.dns_name}"]
    path_matcher = "origin-matcher"
  }

  path_matcher {
    name            = "origin-matcher"
    default_service = google_compute_backend_bucket.default_origin.id
  }
}

# --- Target HTTPS Proxy ---

resource "google_compute_target_https_proxy" "default" {
  name             = "${local.project_shortname}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [data.terraform_remote_state.ips_and_dns.outputs.ssl_certificate_self_link]
}

# --- Global Forwarding Rule ---

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${local.project_shortname}-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
  ip_address = data.terraform_remote_state.ips_and_dns.outputs.gclb_ip_address
}
