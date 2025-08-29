# Kubernetes Example: AWS k3s + MetalLB + Hello World

## Overview
This project demonstrates a streamlined, reliable, and minimal setup for deploying a k3s Kubernetes cluster on AWS EC2, with MetalLB for LoadBalancer support and a publicly accessible Hello World app.

## Key Features
- **Terraform Networking:**
  - VPC, public subnet, internet gateway, route table, security group, and NACL are defined with only required rules.
  - Security group allows SSH (22), HTTP (80), app port (8080), and ICMP (ping) from anywhere.
  - NACL allows all traffic for demo reliability.
  - Subnet and EC2 instance are configured for public IP assignment.
  - All resources are tagged for clarity.
- **Instance Bootstrapping:**
  - `cluster/k3s_install.sh` disables all OS firewalls, installs k3s, patches kubeconfig for public IP, and installs MetalLB.
  - Clear logging for each step.
- **CI/CD Workflow:**
  - Validates AWS resources and EC2 connectivity (SSH, HTTP, ICMP) after provisioning.
  - Fails fast and prints actionable debug info if connectivity fails.
  - Deploys Hello World app in a dedicated namespace and outputs the external IP.
- **Outputs:**
  - Terraform outputs for security group, subnet, NACL, and public IP for workflow and manual validation.
- **Cleanup:**
  - Aggressive cleanup script provided to destroy all resources except the VPC.

## How It Works
1. **Provision Infrastructure:**
   - Run `terraform init` and `terraform apply` in the `infra` directory.
2. **Deploy k3s Cluster:**
   - EC2 instance boots, disables firewalls, installs k3s, and sets up MetalLB.
3. **CI/CD Workflow:**
   - Validates AWS resources and EC2 connectivity.
   - Deploys Hello World app and outputs its public IP.
4. **Cleanup:**
   - Run the cleanup script to destroy resources when finished.

## Troubleshooting
- If EC2 is not reachable, check AWS Console for security group, NACL, subnet, and public IP assignment.
- Use workflow output and Terraform outputs for manual validation.
- For production, re-enable and properly configure OS firewalls and restrict security group access.

## Files
- `infra/main.tf`: Terraform networking and EC2 provisioning.
- `infra/outputs.tf`: Terraform outputs for key resources.
- `cluster/k3s_install.sh`: Instance bootstrapping and k3s/MetalLB setup.
- `.github/workflows/deploy.yml`: CI/CD workflow for deployment and validation.
- `infra/cleanup.sh`: Resource cleanup script.

## Notes
- This setup is for demo and learning purposes. For production, follow AWS and Kubernetes security best practices.
