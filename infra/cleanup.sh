#!/bin/bash
# Automated cleanup script for AWS resources created by Terraform

set -euo pipefail

cd "$(dirname "$0")"

echo "Destroying all Terraform-managed resources..."
terraform destroy -auto-approve

echo "Cleanup complete."
