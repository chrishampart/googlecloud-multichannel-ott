output "tfstate_bucket_name" {
  description = "The globally unique name of the GCS bucket for storing Terraform state. Before using the rest of the Deployments in this Terraform Project, you need to add this bucket name into the backend.tf in each of the Deployments in this proejct. This is so that each Deployment maintains it's state in the common GCS Bucket and each Deployment can reference the state of the other Deployments"
  value       = google_storage_bucket.tfstate.name
}