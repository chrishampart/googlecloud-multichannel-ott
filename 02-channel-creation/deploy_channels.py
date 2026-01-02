#!/usr/bin/env python3

import argparse
import subprocess
import json
import sys
from google.cloud.video.live_stream_v1.services.livestream_service import LivestreamServiceClient

def get_existing_channels(project_id, location):
    """
    Lists existing channels using the Cloud Client Library directly
    to avoid parsing human-readable output of list_channels.py.
    """
    client = LivestreamServiceClient()
    parent = f"projects/{project_id}/locations/{location}"
    try:
        page_result = client.list_channels(parent=parent)
        channels = []
        for response in page_result:
            # Channel name format: projects/{project_id}/locations/{location}/channels/{channel_id}
            channel_id = response.name.split('/')[-1]
            channels.append(channel_id)
        return channels
    except Exception as e:
        print(f"Error listing channels: {e}")
        # Fallback or exit? For now, let's treat it as fatal since we need to know the count.
        sys.exit(1)

def get_common_var(var_name):
    """
    Reads a variable value from ../common.tfvars.
    Very basic parsing: looks for 'var_name = "value"'
    """
    try:
        with open("../common.tfvars", "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith(var_name):
                    # Expect: region = "europe-west3"
                    parts = line.split("=")
                    if len(parts) >= 2:
                        value = parts[1].strip().strip('"').strip("'")
                        return value
    except FileNotFoundError:
        pass
    return None

def main():
    default_region = get_common_var("region") or "us-central1"

    parser = argparse.ArgumentParser(description="Deploy Livestream Channels Interactively")
    parser.add_argument("--project_id", required=True, help="GCP Project ID")
    parser.add_argument("--location", default=default_region, help=f"GCP Region (default: {default_region})")
    args = parser.parse_args()

    print(f"Checking existing channels in {args.project_id}/{args.location}...")
    existing_channels = get_existing_channels(args.project_id, args.location)
    existing_count = len(existing_channels)
    
    print(f"Found {existing_count} existing channels.")
    if existing_channels:
        print(f"Current channels: {', '.join(existing_channels)}")

    while True:
        try:
            num_new_str = input("How many new channels would you like to create? (Enter 0-10): ")
            num_new = int(num_new_str)
            if 0 <= num_new <= 10:
                break
            print("Please enter a number between 0 and 10.")
        except ValueError:
            print("Invalid input. Please enter a number.")

    if num_new == 0:
        print("No new channels to create. Verifying existing configuration...")

    # Calculate new channel configurations
    # Existing naming convention: channel01, channel02, ...
    # We need to find the next available index.
    # Simple strategy: Parse the highest number from existing channels or just increment count?
    # User requirement: "channel01-input" -> "channel01"
    
    # Let's determine the next start index.
    # If we have channel01, channel02... next is 03.
    # If we have no channels, start at 1.
    # Note: If existing channels don't follow pattern, we might need a robust way.
    # For now, let's assume they might be sparse or non-standard, but we will append new ones with standard names 
    # starting from (existing_count + 1). 
    # WAIT: If user deleted channel02 but kept channel03, just appending might collide if we used count.
    # Safer: Find max index used in 'channelNN' pattern.
    
    start_index = 1
    import re
    max_idx = 0
    pattern = re.compile(r"channel(\d+)$")
    for ch in existing_channels:
        m = pattern.match(ch)
        if m:
            idx = int(m.group(1))
            if idx > max_idx:
                max_idx = idx
    
    start_index = max_idx + 1

    new_channels = []
    print("\nPlanning to create:")
    for i in range(num_new):
        idx = start_index + i
        # Format with leading zero if < 10, though 'channel01' suggests 2 digits.
        # Let's ensure at least 2 digits.
        suffix = f"{idx:02d}"
        channel_id = f"channel{suffix}"
        input_id = f"{channel_id}-input"
        
        print(f" - Channel: {channel_id}, Input: {input_id}")
        new_channels.append({"id": channel_id, "input_id": input_id})

    confirm = input("\nProceed with Terraform apply? (y/n): ")
    if confirm.lower() != 'y':
        print("Aborted.")
        return

    # Construct Terraform variable
    # We need to pass the list of objects.
    # Terraform expects -var 'channels=[{id="...", input_id="..."}]'
    # We need to generate TFvars or JSON.
    
    # Let's just create a temporary tfvars file or pass strict JSON.
    # 'terraform apply -var-file=...' is clean.
    
    tfvars_content = {
        "channels": new_channels,
        "project_id": args.project_id,
        "region": args.location
        # Note: terraform_state_bucket is required but usually in common.tfvars or similar?
        # The user's prompt implies we are modifying this module which has variables.
        # We should respect existing variables if possible.
        # But we need to pass the *new* list.
        # Wait, if we use -var("channels=..."), does it override? Yes.
        # But what about persistence? If we run TF again without this var, they might be destroyed if the variable defaults to [].
        # Terraform state tracks them, but if the code says `count = length(var.channels)` and var.channels is empty, 
        # it will destroy them!
        
        # CRITICAL: We need to INCLUDE existing channels in the list if we want to keep them, 
        # OR this module is only for *new* creation?
        # If I use `count` in Terraform, it manages the *entire* set.
        # If I pass `channels` = [new ones] and exclude old ones, Terraform will DESTROY old ones.
        # So we MUST discover existing ones and include them in the `var.channels` list passed to Terraform,
        # UNLESS the exiting ones were created by a *different* state or manually.
        # User said: "Create between 1 and 10 Channel Inputs... corresponding 1-10 Channels"
        # "There are 'n' channels running. How many new channels would you like to create?"
        
        # IF these resources are managed by THIS terraform state, we MUST preserve the full list.
        # If I run `terraform show -json` I could see what is currently in state.
        # But `list_channels` (API) is the source of truth for *what exists*, not necessarily *what is in state*.
        # However, for `null_resource` tracking, state is key.
        
        # Assumption: The user wants to *manage* these channels via this Terraform module.
        # So we should reconstruct the list of *all* desired channels (existing + new) and pass that.
        # But wait, if we include existing channels in the list, `create_channel.py` might fail if it tries to create them again?
        # Or does `create_channel.py` handle idempotency (check if exists)?
        # Let's check `create_channel.py`.
    }
    
    # We need to be careful. If `create_channel.py` fails on "already exists", we can't blindly include existing ones 
    # unless the script handles it graceously or we filter them out in TF (which is hard with `count`).
    # Ideally, `create_channel.py` should say "Channel exists, updating or skipping" and exit 0.
    # I read `create_channel.py` earlier: 
    # `operation = client.create_channel(...)` -> This WILL throw "Already Exists" (409) if it exists.
    # So our Python script triggers MUST be idempotent or the script must be.
    
    # Option 1: Update `create_channel.py` to handle 409 politely.
    # Option 2: Only pass *new* channels to Terraform?
    # -> If we use `count = length(var.channels)`, and we only pass new ones, TF will validly delete the old ones from state (and trigger their destroy provisioners if any!).
    # -> We MUST pass the full list.
    
    # Therefore, we MUST update `create_channel.py` (and input script) to be idempotent.
    # AND we must construct the full list of channels (old + new).
    
    # For this task, I will generate the wrapper script to calculate the FULL list.
    # And I will mark a task to Update Python scripts for idempotency.
    
    all_channels = []
    # Reconstruct objects for existing channels
    # We assume standard naming: channelXX -> input: channelXX-input
    for ch in existing_channels:
        all_channels.append({"id": ch, "input_id": f"{ch}-input"})
        
    all_channels.extend(new_channels)
    
    # Verify we don't exceed limits or duplicates?
    # (Leaving basic for now)

    import json
    tf_channels_json = json.dumps(all_channels)
    
    # Construct command
    # We assume 'common.tfvars' is used for other vars, or we need to pass them.
    # The user manual mentioned `common.tfvars` in root.
    # We should probably include `-var-file=../common.tfvars` if it exists.
    # Or rely on user to run this script from the correct dir with correct environment.
    # The prompt implies running this replaces `terraform apply`.
    
    cmd = [
        "terraform", "apply",
        "-var", f"channels={tf_channels_json}",
        "-var", f"project_id={args.project_id}",
        "-var", f"region={args.location}",
        "-var-file=../common.tfvars", # Heuristic based on project structure
        "-auto-approve"
    ]
    
    print("\nRunning Terraform with updated channel list...")
    subprocess.run(cmd, check=True)

if __name__ == "__main__":
    main()
