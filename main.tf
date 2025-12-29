resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "default" {
  name          = "${var.bucket_name}-${random_id.bucket_suffix.hex}"
  location      = var.location
  force_destroy = false # Set to true to allow deletion of non-empty buckets

  uniform_bucket_level_access = true

  project = var.project_id
}
 
resource "google_project_service" "apis" {
  for_each = toset(var.gcp_service_list)
  project  = var.project_id
  service  = each.key

  # Do not disable the API when the resource is destroyed.
  disable_on_destroy = false
}

resource "google_video_livestream_input" "default" {
  name     = var.livestream_input_name
  location = var.location # Using var.location for consistency
  type     = "SRT_PUSH" # Can be RTMP_PUSH or SRT_PUSH
  project  = var.project_id

  depends_on = [
    google_project_service.apis["livestream.googleapis.com"]
  ]
}