output "default_origin_bucket_name" {
  description = "The name of the GCS bucket for the default origin."
  value       = google_storage_bucket.origin_buckets["default"].name
}

output "stream_origin_bucket_name" {
  description = "The name of the GCS bucket for the stream origin."
  value       = google_storage_bucket.origin_buckets["stream"].name
}

output "web_origin_bucket_name" {
  description = "The name of the GCS bucket for the web/static content origin."
  value       = google_storage_bucket.origin_buckets["web"].name
}

output "tfstate_bucket_name" {
  description = "The name of the GCS bucket for storing Terraform state."
  value       = google_storage_bucket.tfstate.name
}

output "project_shortname" {
  description = "A short name for the project, used as a prefix for resources and subdomains"
  value       = var.project_shortname
}
