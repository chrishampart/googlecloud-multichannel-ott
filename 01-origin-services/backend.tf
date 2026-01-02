terraform {
  backend "gcs" {
    # This bucket is created by the `00-tfstate-bootstrap` deployment.
    # 1. Run `terraform apply` in the `00-tfstate-bootstrap` directory.
    # 2. Copy the output `tfstate_bucket_name`.
    # 3. Paste the bucket name here.
    #
    # This value must be a hardcoded string.
    bucket = "omega-champart-scratch-tfstate" # <-- PASTE BUCKET NAME FROM BOOTSTRAP OUTPUT
    prefix = "terraform/state/01-origin-services"
  }
}