output "live_source_vm_ips" {
  description = "A list of the public IP addresses of the live source VMs."
  value       = [for vm in google_compute_instance.live_source_vm : vm.network_interface[0].access_config[0].nat_ip]
}
output "channel_input_uris" {
  description = "URIS from 02-channel-creation"
  value       = data.terraform_remote_state.channel_creation.outputs.input_uris
}
