# 02 - Channel Creation

This Terraform configuration is a wrapper for scripts that create Google Cloud Live Stream API resources.

The Live Stream API does not currently have a native Terraform provider, so these resources are managed via a Python script called by a `null_resource`.

## Usage

1.  Ensure the `01-origin-services` part has been deployed successfully.
2.  Run `terraform init` and `terraform apply`. This will execute the script in the `scripts/` directory.