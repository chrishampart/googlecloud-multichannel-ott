resource "google_compute_firewall" "allow_iap_ssh" {
  # Create this rule only if the default network is being used.
  count   = var.vpc_network_name == "default" ? 1 : 0
  project = var.project_id
  name    = "allow-from-iap"
  network = var.vpc_network_name

  description = "Allow SSH access from Google Cloud's Identity-Aware Proxy"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # This is the IP range for IAP TCP forwarding.
  target_tags   = ["allow-iap-ssh"]
}