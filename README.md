# Google Cloud Multi-Channel OTT Infrastructure

This repository contains Terraform code to provision the foundational infrastructure for a multi-channel Over-The-Top (OTT) video streaming solution on Google Cloud Platform (GCP).

It sets up the necessary APIs and a Google Cloud Storage bucket required for a video workflow using the [Live Stream API](https://cloud.google.com/livestream) and Google Cloud CDN.

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
    project_id = "your-gcp-project-id"
    region     = "europe-west1"
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

