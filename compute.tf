resource "google_compute_address" "live_source_ip" {
  count   = var.number_of_live_source_vms
  project = var.project_id
  name    = format("live-source%02d-ipv4", count.index + 1)
  region  = var.region
  network_tier = var.network_tier
}

resource "google_compute_instance" "live_source_vm" {
  count        = var.number_of_live_source_vms
  project      = var.project_id
  zone         = var.zone # e.g. "us-central1-b"
  name         = format("live-source%02d", count.index + 1)
  machine_type = "c2d-standard-2"
  tags         = ["http-server", "https-server", "allow-iap-ssh"] # For potential firewall rules

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network    = var.vpc_network_name
    subnetwork = var.vpc_subnetwork_name
    access_config {
      // Assign the static IP
      nat_ip = google_compute_address.live_source_ip[count.index].address
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