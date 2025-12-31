terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
  # Configure the GCS backend to read outputs from the previous step
  backend "gcs" {
    # This will be configured during `terraform init`
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Read the output from the '01-origin-services' state
data "terraform_remote_state" "origin_services" {
  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = "terraform/state/01-origin-services"
  }
}

resource "null_resource" "create_livestream_channels" {
  # This provisioner will run your Python script.
  # It will re-run if the number of channels changes.
  triggers = {
    channel_count = var.number_of_channels
    stream_bucket = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
  }

  provisioner "local-exec" {
    # Example command to run your script. You will need to build out this script.
    command = "python3 ${path.module}/scripts/create_livestream_resources.py --project-id ${var.project_id} --location ${var.region} --channel-count ${var.number_of_channels} --output-bucket ${self.triggers.stream_bucket}"
  }
}