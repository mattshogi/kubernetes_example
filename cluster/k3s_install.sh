#!/bin/bash
# k3s installation script
# This script installs k3s on an EC2 instance and sets up kubeconfig for the default user

set -euo pipefail

# Install k3s with public IP as TLS SAN
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--tls-san $(hostname -I | awk '{print $1}')" sh -

# Wait for kubelet to be ready
while ! kubectl get nodes >/dev/null 2>&1; do sleep 5; done

# Copy kubeconfig to home directory of default user
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Print public IP for debugging
echo "Kubeconfig is at /home/ec2-user/.kube/config"

# End of script
