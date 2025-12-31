variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "project_shortname" {
  description = "A short name for the project, used as a prefix for resources."
  type        = string
  default     = "ott"
}

variable "fqdn" {
  description = "The fully qualified parent domain name that you own and will delegate from (e.g., 'example.com')."
  type        = string
}