# Google Cloud Multi-Channel OTT Infrastructure

This repository contains Terraform code to provision the foundational infrastructure for a multi-channel Over-The-Top (OTT) video streaming solution on Google Cloud Platform (GCP).

It sets up the necessary APIs, a live source VM, and a Google Cloud Storage bucket required for a video workflow using the [Live Stream API](https://cloud.google.com/livestream).

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.0.0 or later)
2.  [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3.  A Google Cloud Project with billing enabled.
4.  Authenticated the gcloud CLI with your user account or a service account:
    ```bash
    gcloud auth application-default login
    ```

## Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/chrishampart/googlecloud-multichannel-ott.git
    cd googlecloud-multichannel-ott
    ```

2.  **Configure your variables:**
    Create a `terraform.tfvars` file in the root of the project and add the required variables. The only required variable is `project_id`.

    ```terraform
    # terraform.tfvars
    project_id                = "your-gcp-project-id" # e.g. "my-gcp-project-123"
    region                    = "europe-west3"      # e.g. "us-central1"
    vpc_network_name          = "my-custom-vpc"     # Optional, defaults to "default"
    vpc_subnetwork_name       = "my-custom-subnet"  # Optional, required for non-auto-mode VPCs
    network_tier              = "PREMIUM"           # Optional, defaults to "STANDARD"
    ```

3.  **Initialize Terraform:**
    This will download the necessary providers.
    ```bash
    terraform init
    ```

4.  **Plan the deployment:**
    Review the resources that Terraform will create.
    ```bash
    terraform plan
    ```

5.  **Apply the configuration:**
    This will provision the resources in your GCP project.
    ```bash
    terraform apply
    ```

## Networking

By default, this configuration deploys resources into the `default` VPC network. When using the default network, a firewall rule named `allow-from-iap` is automatically created. This rule allows SSH access to the VMs via Google Cloud's Identity-Aware Proxy, which is a more secure method than exposing SSH ports directly to the internet.
