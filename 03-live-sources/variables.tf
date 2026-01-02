variable "project_id" {
  description = "The Google Cloud project ID to deploy resources into."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The Google Cloud zone to deploy resources into."
  type        = string
  default     = "us-central1-b"
}

variable "number_of_live_source_vms" {
  description = "The number of live source VMs to create."
  type        = number
  default     = 1
}

variable "vpc_network_name" {
  description = "The name of the VPC network to deploy the VMs into."
  type        = string
  default     = "default"
}

variable "vpc_subnetwork_name" {
  description = "The name of the VPC subnetwork to deploy the VMs into. Required if the network is not in auto-mode."
  type        = string
  default     = null # Allows it to work with auto-mode VPCs by default
}

variable "network_tier" {
  description = "The network tier to use for the external IP address of the VM. Can be STANDARD or PREMIUM."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "PREMIUM"], var.network_tier)
    error_message = "The network_tier must be either STANDARD or PREMIUM."
  }
}
variable "terraform_state_bucket" {
  description = "The name of the GCS bucket used for Terraform state storage."
  type        = string
}
