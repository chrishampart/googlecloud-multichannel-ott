output "bucket_url" {
  description = "The URL of the created GCS bucket."
  value       = google_storage_bucket.default.url
}

output "livestream_input_uri" {
  description = "The SRT push URI for the Live Stream input. This contains the stream key."
  value       = google_video_livestream_input.default.uri
  sensitive   = true
}