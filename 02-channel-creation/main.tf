terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
  # GCS is configured as the backend in backend.tf
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Read the output from the '01-origin-services' state
data "terraform_remote_state" "origin_services" {
  backend = "gcs"
  config = {
    # This correctly uses the bucket configured in the backend.
#    bucket = terraform.backend.config.bucket
    bucket = var.terraform_state_bucket
    prefix = "terraform/state/01-origin-services"
  }
}

resource "null_resource" "create_livestream_channels" {
  count = length(var.channels)

  triggers = {
    channel_id    = var.channels[count.index].id
    input_id      = var.channels[count.index].input_id
    stream_bucket = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
    project_id    = var.project_id
    region        = var.region
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Creating Input: ${self.triggers.input_id}..."
      ${path.module}/venv/bin/python3 ${path.module}/live-stream/create_input.py \
        --project_id ${self.triggers.project_id} \
        --location ${self.triggers.region} \
        --input_id ${self.triggers.input_id} \
        --input_type SRT_PUSH

      echo "Creating Channel: ${self.triggers.channel_id}..."
      ${path.module}/venv/bin/python3 ${path.module}/live-stream/create_channel2.py \
        --project_id ${self.triggers.project_id} \
        --location ${self.triggers.region} \
        --channel_id ${self.triggers.channel_id} \
        --input_id ${self.triggers.input_id} \
        --output_uri ${self.triggers.stream_bucket}/live/${self.triggers.channel_id}

      echo "Updating Channel Logs: ${self.triggers.channel_id}..."
      ${path.module}/venv/bin/python3 ${path.module}/live-stream/update_channel.py \
        --project_id ${self.triggers.project_id} \
        --location ${self.triggers.region} \
        --channel_id ${self.triggers.channel_id} \
        --input_id ${self.triggers.input_id} \
        --log_config INFO

      echo "Starting Channel: ${self.triggers.channel_id} (Timeout 30s)..."
      timeout 30s ${path.module}/venv/bin/python3 ${path.module}/live-stream/start_channel.py \
        --project_id ${self.triggers.project_id} \
        --location ${self.triggers.region} \
        --channel_id ${self.triggers.channel_id} || true

      echo "Checking Channel Status: ${self.triggers.channel_id}..."
      ${path.module}/venv/bin/python3 ${path.module}/live-stream/get_channel.py \
        --project_id ${self.triggers.project_id} \
        --location ${self.triggers.region} \
        --channel_id ${self.triggers.channel_id}
    EOT
  }
}

data "external" "input_uris" {
  program = ["${path.module}/venv/bin/python3", "${path.module}/live-stream/get_input_uris.py", "--project_id", var.project_id, "--location", var.region]
  
  depends_on = [null_resource.create_livestream_channels]
}