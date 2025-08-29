#!/bin/bash
# Automated cleanup script for AWS resources created by Terraform

set -euo pipefail

cd "$(dirname "$0")"

echo "Destroying all Terraform-managed resources..."

terraform destroy -auto-approve

#echo "Terminating all running EC2 instances..."
#aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text | xargs -r aws ec2 terminate-instances --instance-ids || echo "No running EC2 instances to terminate."

echo "Cleanup complete."
