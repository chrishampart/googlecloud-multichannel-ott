variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "terraform_state_bucket" {
  description = "The name of the GCS bucket where Terraform state is stored."
  type        = string
}