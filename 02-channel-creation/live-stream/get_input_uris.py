#!/usr/bin/env python

# Copyright 2022 Google LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Google Cloud Live Stream sample for listing input URIs as JSON.
Example usage:
    python get_input_uris.py --project_id <project-id> --location <location>
"""

import argparse
import json
import sys

from google.cloud.video import live_stream_v1
from google.cloud.video.live_stream_v1.services.livestream_service import (
    LivestreamServiceClient,
)


def get_input_uris(project_id: str, location: str):
    """Lists inputs and prints their URIs as JSON."""

    client = LivestreamServiceClient()
    parent = f"projects/{project_id}/locations/{location}"
    
    # Initialize dictionary to store results
    result = {}

    try:
        # Pager object
        inputs = client.list_inputs(parent=parent)

        for input_ in inputs:
            # input_.name is full path: projects/{p}/locations/{l}/inputs/{id}
            # We extracting just the ID for cleaner keys.
            input_id = input_.name.split("/")[-1]
            if input_.uri:
                result[input_id] = input_.uri
            else:
                result[input_id] = "" # Or skip? Empty string is safer for TF map

        # Print JSON to stdout for Terraform to capture
        print(json.dumps(result))

    except Exception as e:
        # Terraform expects a JSON error or we can just exit non-zero
        # But for data "external", printing valid JSON is best.
        # If we fail, we might print an error to stderr and exit 1
        sys.stderr.write(f"Error fetching inputs: {e}\n")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--project_id", help="Your Cloud project ID.", required=True)
    parser.add_argument(
        "--location",
        help="The location of the input.",
        required=True,
    )
    args = parser.parse_args()
    get_input_uris(
        args.project_id,
        args.location,
    )
