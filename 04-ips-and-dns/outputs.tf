output "managed_zone_name" {
  description = "The name of the created Cloud DNS managed zone."
  value       = google_dns_managed_zone.main.name
}

output "managed_zone_dns_name" {
  description = "The DNS name of the created zone (e.g., 'ott.example.com.')."
  value       = google_dns_managed_zone.main.dns_name
}

output "name_servers" {
  description = "The name servers to delegate to from your parent domain's registrar."
  value       = google_dns_managed_zone.main.name_servers
}

output "gclb_ip_address" {
  description = "The global IP address reserved for the load balancer."
  value       = google_compute_global_address.gclb_ip.address
}

output "ssl_certificate_self_link" {
  description = "The self-link of the created Google-managed SSL certificate."
  value       = google_compute_managed_ssl_certificate.default.self_link
}