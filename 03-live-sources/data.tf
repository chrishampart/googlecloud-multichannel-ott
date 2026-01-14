data "terraform_remote_state" "channel_creation" {
  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = "terraform/state/02-channel-creation"
  }
}
