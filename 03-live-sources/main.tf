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
  for_each     = data.terraform_remote_state.channel_creation.outputs.input_uris
  project      = var.project_id
  name         = "live-source-${each.key}-ipv4"
  region       = var.region
  network_tier = var.network_tier
}

resource "google_compute_instance" "live_source_vm" {
  for_each     = data.terraform_remote_state.channel_creation.outputs.input_uris
  project      = var.project_id
  zone         = var.zone
  name         = "live-source-${each.key}"
  machine_type = var.machine_type
  tags         = ["http-server", "https-server", "allow-iap-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network    = var.vpc_network_name
    subnetwork = var.vpc_subnetwork_name
    access_config {
      nat_ip       = google_compute_address.live_source_ip[each.key].address
      network_tier = var.network_tier
    }
  }

  // This startup script runs once on the first boot
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y ffmpeg

    # Create the streaming script
    cat <<'EOF' > /usr/local/bin/stream_loop.sh
    #!/bin/bash
    
    # allow for upload of a .mp4 or .ts file to replace the default test card
    # if a file named input.mp4 exists in /root/ then stream that instead
    
    INPUT_FILE="testsrc2=size=1920x1080:rate=30 [out0]; sine=frequency=500 [out1]"
    INPUT_FORMAT="-f lavfi"
    
    if [ -f /root/input.mov ]; then
      INPUT_FILE="/root/input.mov"
      INPUT_FORMAT=""
    elif [ -f /root/input.mp4 ]; then
      INPUT_FILE="/root/input.mp4"
      INPUT_FORMAT=""
    elif [ -f /root/input.ts ]; then
      INPUT_FILE="/root/input.ts"
      INPUT_FORMAT=""
    fi

    /usr/bin/ffmpeg -re -stream_loop -1 $INPUT_FORMAT -i "$INPUT_FILE" \
      -vf "drawtext=text='Google Cloud Live Stream API':x=w*0.03:y=h*0.07:fontsize=72:fontcolor=white:box=1:boxcolor=black, drawtext=text='${title(replace(each.key, "-", " "))}':x=w*0.03:y=h*0.07+85:fontsize=72:fontcolor=white:box=1:boxcolor=black" \
      -acodec aac -vcodec h264 -preset ultrafast \
      -f mpegts "${each.value}"
    EOF

    chmod +x /usr/local/bin/stream_loop.sh

    # Create the systemd service
    cat <<EOF > /etc/systemd/system/live-stream.service
    [Unit]
    Description=FFmpeg Live Stream
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/stream_loop.sh
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    EOF

    systemctl daemon-reload
    systemctl enable live-stream
    systemctl start live-stream
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