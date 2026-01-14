output "load_balancer_ip" {
  description = "The public IP address of the Global Load Balancer."
  value       = google_compute_global_forwarding_rule.default.ip_address
}