variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "terraform_state_bucket" {
  description = "Where to read the config of the other Deployments from"
  type        = string
}

variable "channels" {
  description = "List of channels to create, each with an id and input_id."
  type = list(object({
    id       = string
    input_id = string
  }))
  default = []
}