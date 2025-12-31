# This file configures the remote backend for Terraform state storage.
# The state for this section will be stored in the GCS bucket created by the 01-origin-services section.

terraform {
  backend "gcs" {
    # Replace this with the actual bucket name from the 01-origin-services output
    bucket = "ott-tfstate-xxxxxxxx"
    # This prefix creates a "folder" in the bucket for this section's state file
    prefix = "terraform/state/channel-creation"
  }
}