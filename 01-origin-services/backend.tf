terraform {
  backend "gcs" {
    # The bucket name must be globally unique.
    # Using the project ID is a good way to ensure this.
    # This must be a hardcoded, globally-unique bucket name.
    # The bucket name must be a hardcoded string because Terraform reads this
    # configuration during `terraform init`, *before* it evaluates variables.
    # Using your unique GCP Project ID is a best practice to ensure the
    # bucket name is globally unique.
    # It should match the 'google_storage_bucket.tfstate' resource in main.tf
    bucket = "<YOUR-PROJECT-ID>-tfstate"
    prefix = "terraform/state/01-origin-services"
  }
}