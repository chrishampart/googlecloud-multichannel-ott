variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "number_of_channels" {
  description = "The number of Live Stream API channels and inputs to create."
  type        = number
  default     = 1
}

variable "terraform_state_bucket" {
  description = "The name of the GCS bucket where Terraform state is stored."
  type        = string
}