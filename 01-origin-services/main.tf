# Enable the necessary APIs for the entire project
resource "google_project_service" "apis" {
  for_each = toset(var.gcp_service_list)
  project  = var.project_id
  service  = each.key

  # Do not disable the API when the resource is destroyed.
  disable_on_destroy = false
}

# A loop to create the three different types of public origin buckets
resource "google_storage_bucket" "origin_buckets" {
  for_each      = var.origin_bucket_locations
  project       = var.project_id
  name          = "${var.project_shortname}-${each.key}-origin"
  location      = each.value.location
  force_destroy = true # Set to false in production
  rpo           = each.value.rpo

  uniform_bucket_level_access = true

  # This block defines the specific dual-region pairing if provided
  dynamic "custom_placement_config" {
    for_each = each.value.custom_data_locations != null ? [1] : []
    content {
      data_locations = each.value.custom_data_locations
    }
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3
  }

  # The project service resources should be created before the buckets
  depends_on = [google_project_service.apis]
}

# A separate, private bucket to store Terraform state files
resource "google_storage_bucket" "tfstate" {
  project       = var.project_id
  name          = "${var.project_id}-tfstate"
  location      = var.region
  force_destroy = false # This should always be false for state buckets

  uniform_bucket_level_access = true

  # Enable versioning to keep a history of your state files
  versioning {
    enabled = true
  }
}

# Make buckets publicly readable for the CDN
resource "google_storage_bucket_iam_member" "public_viewer" {
  for_each = google_storage_bucket.origin_buckets
  bucket   = each.value.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

resource "random_id" "suffix" {
  byte_length = 4
}