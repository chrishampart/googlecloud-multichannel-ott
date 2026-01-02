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

This project is organized into sequential stages (00-05). You must deploy them in order.

### prerequisites coverage

1.  **Install tools:**
    - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v1.0.0 or later)
    - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
    - **Python 3, pip, and venv**:
      ```bash
      sudo apt update && sudo apt install -y python3-venv python3-pip
      ```
    - **Python dependencies**:
      Create a virtual environment and verify the library is installed:
      ```bash
      cd 02-channel-creation
      python3 -m venv venv
      source venv/bin/activate
      pip install google-cloud-video-live-stream
      ```

2.  **Clone the repository:**
    ```bash
    git clone https://github.com/chrishampart/googlecloud-multichannel-ott.git
    cd googlecloud-multichannel-ott
    ```

3.  **Configure your variables:**
    Create a `common.tfvars` file in the root of the project. This file will be used by all stages.

    ```terraform
    # common.tfvars
    project_id                = "your-gcp-project-id"
    region                    = "europe-west3"
    project_shortname         = "ott"
    terraform_state_bucket    = "your-unique-state-bucket-name"
    ```

### Deployment Steps

1.  **00-tfstate-bootstrap**: Creates the remote state bucket.
    ```bash
    cd 00-tfstate-bootstrap
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```
    *Note: After this step, ensure your `backend.tf` files in other directories point to the bucket name you defined.*

2.  **01-origin-services**: Deploys origin storage and APIs.
    ```bash
    cd ../01-origin-services
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```

3.  **02-channel-creation**: Configures Live Stream API channels.
    *Requires Python dependency installed (active venv).*
    ```bash
    cd ../02-channel-creation
    source venv/bin/activate
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```

4.  **03-live-sources**: Deploys live source VMs.
    ```bash
    cd ../03-live-sources
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```

5.  **04-ips-and-dns**: Sets up static IPs and DNS.
    ```bash
    cd ../04-ips-and-dns
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```

6.  **05-load-balancer**: Deploys the Load Balancer.
    ```bash
    cd ../05-load-balancer
    terraform init
    terraform apply -var-file="../common.tfvars"
    ```

## Networking

## Networking

By default, this configuration deploys resources into the `default` VPC network. When using the default network, a firewall rule named `allow-from-iap` is automatically created. This rule allows SSH access to the VMs via Google Cloud's Identity-Aware Proxy, which is a more secure method than exposing SSH ports directly to the internet.
