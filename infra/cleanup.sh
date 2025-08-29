#!/bin/bash
# Automated cleanup script for AWS resources created by Terraform

set -euo pipefail

cd "$(dirname "$0")"

echo "Destroying all Terraform-managed resources..."


terraform destroy -auto-approve

echo "Terminating all running EC2 instances..."
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text | xargs -r aws ec2 terminate-instances --instance-ids || echo "No running EC2 instances to terminate."

echo "Deleting all Internet Gateways..."
for igw in $(aws ec2 describe-internet-gateways --query "InternetGateways[*].InternetGatewayId" --output text); do
	for vpc in $(aws ec2 describe-internet-gateways --internet-gateway-ids $igw --query "InternetGateways[*].Attachments[*].VpcId" --output text); do
		aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc || true
	done
	aws ec2 delete-internet-gateway --internet-gateway-id $igw || true
done

echo "Deleting all VPCs..."
KEEP_VPC=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=k3s-node" --query "Vpcs[*].VpcId" --output text)
for vpc in $(aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text); do
	if [[ "$vpc" != "$KEEP_VPC" ]]; then
		aws ec2 delete-vpc --vpc-id $vpc || true
	fi
done

#echo "Terminating all running EC2 instances..."
#aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text | xargs -r aws ec2 terminate-instances --instance-ids || echo "No running EC2 instances to terminate."

echo "Cleanup complete."
