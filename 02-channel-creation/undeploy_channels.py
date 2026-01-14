#!/usr/bin/env python3

import argparse
import subprocess
import sys
import re
import json
from google.cloud.video.live_stream_v1.services.livestream_service import LivestreamServiceClient

def get_common_var(var_name, common_vars_path="../common.tfvars"):
    """Reads a variable from the common.tfvars file."""
    try:
        with open(common_vars_path, "r") as f:
            for line in f:
                if line.strip().startswith(var_name):
                    match = re.search(r'=\s*"([^"]+)"', line)
                    if match:
                        return match.group(1)
    except FileNotFoundError:
        return None
    return None

def list_channels(project_id, location):
    """
    Lists existing channels and returns them sorted by ID (assuming 'channelNN').
    """
    client = LivestreamServiceClient()
    parent = f"projects/{project_id}/locations/{location}"
    try:
        page_result = client.list_channels(parent=parent)
        channels = []
        for response in page_result:
            channel_id = response.name.split('/')[-1]
            channels.append(channel_id)
        
        # Sort channels naturally (channel2 < channel10) if they follow the pattern
        # Otherwise standard sort
        def natural_keys(text):
            return [int(c) if c.isdigit() else c for c in re.split(r'(\d+)', text)]
            
        channels.sort(key=natural_keys)
        return channels
    except Exception as e:
        print(f"Error listing channels: {e}")
        sys.exit(1)

def run_command(cmd, check=True):
    print(f"Executing: {' '.join(cmd)}")
    subprocess.run(cmd, check=check)

def main():
    parser = argparse.ArgumentParser(description="Undeploy Live Stream channels interactively.")
    parser.add_argument("--project_id", help="GCP Project ID", required=True)
    parser.add_argument("--location", help="GCP Location", default=None)
    
    args = parser.parse_args()

    # Determine region/location
    if not args.location:
        args.location = get_common_var("region")
        if not args.location:
            print("Error: Could not determine region from ../common.tfvars and --location not provided.")
            sys.exit(1)

    print(f"Checking for resources in {args.project_id}/{args.location}...")

    # 1. List Resources
    channels = list_channels(args.project_id, args.location)
    num_channels = len(channels)

    if num_channels == 0:
        print(f"There are {num_channels} channels running in {args.location}.")
        print("No channels to remove. Running Terraform sync...")
        to_remove = 0
    else:
        print(f"There are {num_channels} channels running in {args.location}:")
        print(f"  {', '.join(channels)}")
        
        while True:
            try:
                ans = input(f"How many would you like to remove? [0-{num_channels}]: ")
                to_remove = int(ans)
                if 0 <= to_remove <= num_channels:
                    break
                print(f"Please enter a number between 0 and {num_channels}.")
            except ValueError:
                print("Invalid input. Please enter a number.")

    channels_to_keep = []
    
    # Logic: Remove highest numbered channels first (LIFO effectively if sorted)
    # If channels are [c01, c02, c03, c04] and we remove 2:
    # We remove c04, then c03. Keep c01, c02.
    
    if to_remove == 0:
        print("\nNo channels selected for removal.")
        channels_to_keep = channels
    else:
        # Identify channels to remove (from end of list)
        remove_list = channels[-to_remove:]
        # Identify channels to keep (from start of list)
        channels_to_keep = channels[:-to_remove]
        
        # Reverse remove_list to delete highest index first
        remove_list.reverse() # e.g. [c04, c03]
        
        print(f"\nPlan to remove {to_remove} channels: {', '.join(remove_list)}")
        print(f"Channels remaining: {', '.join(channels_to_keep)}")
        
        confirm = input("Are you sure you want to proceed? (y/N): ")
        if confirm.lower() != 'y':
            print("Aborted.")
            sys.exit(0)
            
        # Execute removal
        for channel_id in remove_list:
            input_id = f"{channel_id}-input" # Assumption based on naming convention
            
            # STOP
            print(f"\nStopping channel: {channel_id}...")
            # We call stop_channel.py. If it fails (e.g. already stopped), we should probably continue.
            # But the user script might error out.
            # Let's check logic. Assuming the script is robust or we catch it.
            run_command([
                "./venv/bin/python3", "live-stream/stop_channel.py",
                "--project_id", args.project_id,
                "--location", args.location,
                "--channel_id", channel_id
            ], check=False)

            # DELETE CHANNEL
            print(f"Deleting channel: {channel_id}...")
            run_command([
                "./venv/bin/python3", "live-stream/delete_channel.py",
                "--project_id", args.project_id,
                "--location", args.location,
                "--channel_id", channel_id
            ], check=False)
            
            # DELETE INPUT
            print(f"Deleting input: {input_id}...")
            run_command([
                "./venv/bin/python3", "live-stream/delete_input.py",
                "--project_id", args.project_id,
                "--location", args.location,
                "--input_id", input_id
            ], check=False)

    # 4. Sync Terraform State
    # We must pass the list of REMAINING channels to Terraform.
    # Construct JSON
    tf_channels = []
    for ch in channels_to_keep:
        tf_channels.append({"id": ch, "input_id": f"{ch}-input"})
        
    tf_channels_json = json.dumps(tf_channels)

    print("\nSyncing Terraform state...")
    cmd = [
        "terraform", "apply",
        "-var", f"channels={tf_channels_json}",
        "-var", f"project_id={args.project_id}",
        "-var", f"region={args.location}",
        "-var-file=../common.tfvars",
        "-auto-approve"
    ]
    
    # We run this even if count is 0, to ensure state is clean/synced.
    run_command(cmd, check=True)
    print("\nOperation complete.")

if __name__ == "__main__":
    main()
