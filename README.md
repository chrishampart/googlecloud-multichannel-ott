# Google Cloud Multi-Channel OTT Infrastructure

This repository contains Terraform code to provision the foundational infrastructure for a multi-channel Over-The-Top (OTT) video streaming solution on Google Cloud Platform (GCP).

It sets up the necessary APIs, a live source VM, and a Google Cloud Storage bucket required for a video workflow using the [Live Stream API](https://cloud.google.com/livestream).

## Quick Start: Cloud Shell

The fastest way to deploy this infrastructure is using Google Cloud Shell.

1.  **Open Cloud Shell**
    Go to [ide.cloud.google.com](https://ide.cloud.google.com) and open a new terminal.

2.  **Clone the Repository**
    ```bash
    git clone https://github.com/chrishampart/googlecloud-multichannel-ott.git
    cd googlecloud-multichannel-ott
    ```

3.  **Configure Environment**
    Set your project variables. These will be used to generate the configuration files.
    ```bash
    export PROJECT_ID=$(gcloud config get-value project)
    export REGION="europe-west3"
    ```

4.  **Create Configuration (common.tfvars)**
    Generate the `common.tfvars` file.
    *Note: We use the shortname 'ott' for resource naming.*
    ```bash
    cat <<EOF > common.tfvars
    project_id = "${PROJECT_ID}"
    region     = "${REGION}"
    zone       = "${REGION}-a"
    project_shortname = "ott"
    terraform_state_bucket = "${PROJECT_ID}-tfstate"
    fqdn       = "reallycloudy.com"
    EOF
    ```

5.  **Bootstrap Infrastructure (Stage 00)**
    Create the remote state bucket.
    ```bash
    cd 00-tfstate-bootstrap
    terraform init
    terraform apply -var-file="../common.tfvars" -auto-approve
    cd ..
    ```

6.  **Fix Backend Configurations**
    Update the `backend.tf` files to point to your new state bucket.
    *This command finds all `backend.tf` files and updates the `bucket` field to match your created bucket.*
    ```bash
    export TF_BUCKET="${PROJECT_ID}-tfstate"
    find . -name "backend.tf" -exec sed -i "s/bucket = \"[^\"]*\"/bucket = \"${TF_BUCKET}\"/g" {} +
    ```

7.  **Deploy Core Infrastructure (Stages 01-05)**
    Run the remaining stages in sequence.

    **Stage 01: Host & Origin Services**
    ```bash
    cd 01-origin-services
    terraform init
    terraform apply -var-file="../common.tfvars" -auto-approve
    cd ..
    ```

    **Stage 02: Deploy Live Channels**
    This step uses a Python script to manage dynamic channel creation.
    ```bash
    cd 02-channel-creation
    
    # Create and activate virtual environment
    python3 -m venv venv
    source venv/bin/activate

    # Install dependencies
    pip install -r live-stream/requirements.txt

    # Run deployment script (enter '2' when asked for number of channels)
    terraform init
    python deploy_channels.py --project_id ${PROJECT_ID}
    cd ..
    ```

    **Stage 03: Live Sources**
    ```bash
    cd 03-live-sources
    terraform init
    terraform apply -var-file="../common.tfvars" -auto-approve
    cd ..
    ```

    **Stage 04: IPs and DNS**
    ```bash
    cd 04-ips-and-dns
    terraform init
    terraform apply -var-file="../common.tfvars" -auto-approve
    cd ..
    ```

    **Stage 05: Global Load Balancer**
    ```bash
    cd 05-load-balancer
    terraform init
    terraform apply -var-file="../common.tfvars" -auto-approve
    cd ..
    ```

## Networking

## Networking

By default, this configuration deploys resources into the `default` VPC network. When using the default network, a firewall rule named `allow-from-iap` is automatically created. This rule allows SSH access to the VMs via Google Cloud's Identity-Aware Proxy, which is a more secure method than exposing SSH ports directly to the internet.
