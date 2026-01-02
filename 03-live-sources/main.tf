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
  region  = var.region
}

resource "google_compute_address" "live_source_ip" {
  count        = var.number_of_live_source_vms
  project      = var.project_id
  name         = format("live-source%02d-ipv4", count.index + 1)
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_instance" "live_source_vm" {
  count        = var.number_of_live_source_vms
  project      = var.project_id
  zone         = var.zone
  name         = format("live-source%02d", count.index + 1)
  machine_type = "c2d-standard-2"
  tags         = ["http-server", "https-server", "allow-iap-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = var.vpc_network_name
    subnetwork = var.vpc_subnetwork_name
    access_config {
      nat_ip       = google_compute_address.live_source_ip[count.index].address
      network_tier = var.network_tier
    }
  }

  // This startup script runs once on the first boot
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y ffmpeg
  EOT

  // Allows the VM to interact with other Google Cloud services
  service_account {
    scopes = ["cloud-platform"]
  }
}

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