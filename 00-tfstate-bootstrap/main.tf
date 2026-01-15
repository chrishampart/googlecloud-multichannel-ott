terraform {
  # This bootstrap project uses the default local backend.
  # A terraform.tfstate file will be created in this directory.
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

# This is the one and only resource this project will manage.
resource "google_storage_bucket" "tfstate" {
  project                     = var.project_id
  # Bucket names must be globally unique.
  name                        = var.terraform_state_bucket
  location                    = var.region
  force_destroy               = false # Critical for state buckets
  uniform_bucket_level_access = true

  # Enable versioning to protect against accidental state deletion or corruption.
  versioning {
    enabled = true
  }

  # Prevent accidental deletion of the state bucket.
  lifecycle {
    prevent_destroy = true
  }
}