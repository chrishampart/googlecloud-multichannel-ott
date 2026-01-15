variable "project_id" {
  description = "Which Google Cloud project ID would you like to deploy resources into? For this multi stage TF project, you can set this in the common.tfvars file in the project root directory and then reference the common.tfvars file (e.g., `terraform plan -var-file=\"../common.tfvars\"`)."
  type        = string
}

variable "project_shortname" {
  description = "A short name for the project, used as a prefix for resources."
  type        = string
  default     = "ott"
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "europe-west3"
}

variable "gcp_service_list" {
  description = "The list of Google Cloud APIs to enable on the project."
  type        = set(string)
  default = [
    "storage.googleapis.com", # For GCS Buckets
    "cloudresourcemanager.googleapis.com", # For Cloud Resource Manager
    "livestream.googleapis.com", # For Live Stream API
    "compute.googleapis.com",    # For Compute Engine (VMs)
    "dns.googleapis.com",        # For Cloud DNS
  ]
}

variable "origin_bucket_locations" {
  description = "A map of bucket configurations. For custom dual-regions, set `location` to the multi-region (e.g., 'EU') and provide the two regions in `custom_data_locations`."
  type = map(object({
    location              = string
    custom_data_locations = optional(list(string))
    rpo                   = optional(string, "DEFAULT")
  }))
  default = {
    "default" = {
      location              = "EU"
      custom_data_locations = ["EUROPE-WEST1", "EUROPE-WEST3"]
      rpo                   = "ASYNC_TURBO"
    },
    "stream" = {
      location              = "EU"
      custom_data_locations = ["EUROPE-WEST1", "EUROPE-WEST3"]
      rpo                   = "ASYNC_TURBO"
    },
    "web" = {
      location              = "EU"
      custom_data_locations = ["EUROPE-WEST1", "EUROPE-WEST3"]
      rpo                   = "ASYNC_TURBO"
    }
  }
}
