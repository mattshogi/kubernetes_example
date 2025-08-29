# kubernetes_example

## Overview

This repo provides a simple, highly available, and scalable Kubernetes cluster starter kit.  
You can deploy locally (minimal resources) or to AWS Free Tier using Terraform.

---

## Layers & Tools

| Layer                | Tool / Why                                                                                           |
|----------------------|------------------------------------------------------------------------------------------------------|
| Local cluster        | **kind** (Kubernetes IN Docker) – Lightweight, single VM/host, <1 GB RAM. Works on Mac/Windows/Linux. |
| Cloud IaC            | **Terraform** + AWS provider – Deploys to AWS Free Tier (t3.micro). Reusable code for local or cloud. |
| CI/CD                | **GitHub Actions** – Free for public repos.                                                          |
| Cost-saving          | Uses free tier instances or local VM with 4 GB RAM + SSD.                                            |

---

## Prerequisites Installation

### Local Deployment (kind)

1. **Install Docker:**
   - macOS: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Windows: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Linux: Follow your distro's instructions ([docs](https://docs.docker.com/engine/install/))

2. **Install kind:**
   - macOS:

     ```sh
     brew install kind
     ```

   - Linux/Windows:

     ```sh
     curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-$(uname)-amd64
     chmod +x ./kind
     mv ./kind /usr/local/bin/kind
     ```

   - [kind installation docs](https://kind.sigs.k8s.io/docs/user/quick-start/)

### AWS Deployment (Terraform)

1. **Install Terraform:**
   - macOS:

     ```sh
     brew tap hashicorp/tap
     brew install hashicorp/tap/terraform
     ```

   - Linux/Windows: [Download Terraform](https://www.terraform.io/downloads.html)

2. **Install AWS CLI:**
   - macOS:

     ```sh
     brew install awscli
     ```

   - Linux/Windows: [AWS CLI install guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. **Configure AWS CLI for Free Tier:**

   ```sh
   aws configure
   ```

   - Enter your AWS credentials and default region (e.g., us-east-1).

---

## Local Cluster Deployment

1. **Create a highly available cluster:**

   ```sh
   kind create cluster --name ha-demo --config kind-ha-config.yaml
   ```

2. **Sample kind-ha-config.yaml:**

   ```yaml
   # kind-ha-config.yaml
   kind: Cluster
   apiVersion: kind.x-k8s.io/v1alpha4
   nodes:
     - role: control-plane
     - role: control-plane
     - role: control-plane
     - role: worker
     - role: worker
   ```

---

## AWS Deployment with Terraform

1. **Initialize and apply Terraform:**

   ```sh
   terraform init
   terraform apply
   ```

2. **Sample main.tf:**

   ```hcl
   # main.tf
   provider "aws" {
     region = "us-east-1"
   }

   resource "aws_instance" "k8s_master" {
     ami           = "ami-0c94855ba95c71c99" # Amazon Linux 2
     instance_type = "t3.micro"
     count         = 3
     tags = { Name = "k8s-master" }
   }

   resource "aws_instance" "k8s_worker" {
     ami           = "ami-0c94855ba95c71c99"
     instance_type = "t3.micro"
     count         = 2
     tags = { Name = "k8s-worker" }
   }
   ```

---

## Project Layout

Your project is organized as follows:

```
├── infra/
│   ├── main.tf          # Terraform config for AWS resources and k3s node
│   ├── variables.tf     # Terraform variables (region, instance type)
│   └── outputs.tf       # Terraform outputs (e.g., kubeconfig)
├── cluster/
│   ├── k3s_install.sh   # Script to install k3s on the instance
│   └── kubeconfig.tpl   # Template for kubeconfig output
└── .github/workflows/deploy.yml # GitHub Actions workflow for CI/CD
```

## AWS k3s Cluster Deployment

This repo uses Terraform to provision a cheap AWS EC2 instance (Free Tier t3.micro) and install k3s (lightweight Kubernetes):

1. **Configure variables** in `infra/variables.tf` (region, instance type)
2. **Provision resources** with `infra/main.tf`:
   - EC2 instance using Amazon Linux 2 AMI
   - Security group allowing all traffic
   - SSH key pair for access
   - User data runs `cluster/k3s_install.sh` to install k3s
3. **Outputs** in `infra/outputs.tf` (e.g., kubeconfig)
4. **K3s install script** (`cluster/k3s_install.sh`) installs k3s and sets up kubeconfig for the default user
5. **Kubeconfig template** (`cluster/kubeconfig.tpl`) for accessing the cluster
6. **CI/CD**: `.github/workflows/deploy.yml` runs Terraform on push to main, applies infrastructure, and exports kubeconfig

## How to Deploy

1. **Install prerequisites** (see above)
2. **Set up AWS credentials** (locally and in GitHub secrets for CI/CD)
3. **Initialize and apply Terraform:**

   ```sh
   cd infra
   terraform init
   terraform apply -auto-approve
   ```

4. **Access your cluster:**
   - Kubeconfig will be available on the instance and can be exported using the template
   - Use SSH to retrieve kubeconfig if needed

## Local Testing: Deploy a Cluster with kind

You can quickly spin up a local Kubernetes cluster for testing using kind.

### Start a Cluster

```sh
kind create cluster --name demo
```

### Deploy an Example App (nginx)

```sh
kubectl apply -f https://k8s.io/examples/application/deployment.yaml
```

### Stop & Clean Up

```sh
kind delete cluster --name demo
```

## Badges

![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-blueviolet)
![AWS Free Tier](https://img.shields.io/badge/AWS-Free%20Tier-success)
![CI/CD](https://img.shields.io/github/workflow/status/mattshogi/kubernetes_example/Deploy%20k3s%20cluster?label=CI%2FCD)

## Troubleshooting & Validation

### Common Issues

- **Terraform errors**: Check AWS credentials, region, and instance type. Ensure your SSH key exists at `~/.ssh/id_rsa.pub`.

- **k3s install fails**: Verify network connectivity and that the EC2 instance has outbound internet access.

- **Kubeconfig not found**: Confirm the install script ran successfully and the file was copied to `/home/ec2-user/.kube/config`.

- **GitHub Actions fails**: Check repo secrets for correct AWS credentials and SSH key.


### Validation Steps

- Run `terraform validate` in the `infra/` directory to check your Terraform files.

- Run `shellcheck cluster/k3s_install.sh` to lint your shell script.

- After deployment, run `kubectl get nodes` using the exported kubeconfig to verify cluster health.

---

## Summary

- **Local cluster:** kind → free, instant, no VM needed.
- **IaC for cloud:** Terraform + k3s_install.sh → works on AWS free tier, or any other provider.
- **CI/CD pipeline:** GitHub Actions (free minutes) to apply Terraform and fetch kubeconfig.

With this stack you can:

- Spin up a cluster locally in seconds.
- Commit the same IaC to GitHub.
- Push → GitHub Action → Terraform provisions an inexpensive VM, installs k3s, outputs kubeconfig.
- Use kubectl from your laptop to talk to either environment.

