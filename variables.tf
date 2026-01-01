variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into. This is set in the common.tfvars file."
  type        = string
}

variable "project_shortname" {
  description = "A short name for the project, used as a prefix for resources."
  type        = string
  default     = "ott"
}

variable "region" {
  description = "The primary Google Cloud region to deploy resources into."
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "The primary Google Cloud zone to deploy resources into."
  type        = string
  default     = "europe-west3-a"
}

variable "terraform_state_bucket" {
  description = "The name of the GCS bucket where Terraform state is stored."
  type        = string
}