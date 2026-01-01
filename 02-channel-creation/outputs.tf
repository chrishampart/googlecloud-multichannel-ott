output "stream_bucket" {
  description = "The name of the GCS bucket for the stream origin, read from the origin_services state."
  value       = data.terraform_remote_state.origin_services.outputs.stream_origin_bucket_name
}