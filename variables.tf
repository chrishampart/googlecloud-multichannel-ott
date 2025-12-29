variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "The location for the GCS bucket (e.g., a region like 'US-CENTRAL1' or a multi-region like 'US')."
  type        = string
  default     = "US-CENTRAL1"
}

variable "bucket_name" {
  description = "The desired name for the GCS bucket. A random suffix will be appended."
  type        = string
  default     = "my-awesome-bucket"
}

variable "gcp_service_list" {
  description = "The list of Google Cloud APIs to enable on the project."
  type        = list(string)
  default = [
    "livestream.googleapis.com",
    "compute.googleapis.com", # For Application Load Balancer
  ]
}