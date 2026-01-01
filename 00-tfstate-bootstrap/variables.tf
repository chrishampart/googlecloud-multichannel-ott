variable "project_id" {
  description = "The Google Cloud project ID to deploy the Terraform state bucket into. This is set in the common.tfvars file."
  type        = string
}

variable "project_shortname" {
  description = "A short name for the project, used as a prefix for the state bucket."
  type        = string
  default     = "ott"
}

variable "region" {
  description = "The Google Cloud region to create the Terraform state bucket in."
  type        = string
  default     = "europe-west3"
}