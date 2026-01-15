terraform {
  backend "gcs" {
    # This bucket is created by the `00-tfstate-bootstrap` deployment.
    # 1. Run `terraform apply` in the `00-tfstate-bootstrap` directory.
    # 2. Copy the output `tfstate_bucket_name`.
    # 3. Paste the bucket name here.
    #
    # This value must be a hardcoded string.
    bucket = "champart-mc-ott-tfstate" # <-- PASTE BUCKET NAME FROM BOOTSTRAP OUTPUT
    prefix = "terraform/state/04-ips-and-dns"
  }
}