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
  # This provisioner will run your Python script.
  # It will re-run if the number of channels changes.
  triggers = {
  #  channel_count = var.number_of_channels
    stream_bucket = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  }
  /*
  provisioner "local-exec" {
    # Example command to run your script. You will need to build out this script.
    command = <<EOT
      set -e
      echo "Executing Livestream creation scripts..."
      
      python3 ${path.module}/live-stream/create_input.py --project-id ${var.project_id} --location ${var.region} --channel-count ${var.number_of_channels} --output-bucket ${self.triggers.stream_bucket} && \
      python3 ${path.module}/live-stream/create_channel.py --project-id ${var.project_id} --location ${var.region} --channel-count ${var.number_of_channels} --output-bucket ${self.triggers.stream_bucket} && \
      python3 ${path.module}/live-stream/create_channel2.py --project-id ${var.project_id} --location ${var.region} --channel-count ${var.number_of_channels} --output-bucket ${self.triggers.stream_bucket}
      
      echo "Livestream scripts finished."
    EOT
  }
  */
  provisioner "local-exec" {
    # Example command to run your script. You will need to build out this script.
    command = <<EOT
      set -e
      echo "Executing Livestream get scripts..."
      
      python3 ${path.module}/live-stream/list_inputs.py --project_id ${var.project_id} --location ${var.region}   && \
      python3 ${path.module}/live-stream/list_channels.py --project_id ${var.project_id} --location ${var.region}  && \
      
      echo "Livestream get scripts finished."
    EOT
  }
}