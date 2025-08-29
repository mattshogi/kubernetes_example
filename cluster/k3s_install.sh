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
EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
if [[ -n "$EC2_PUBLIC_IP" ]]; then
	sed -i "s/server: https:\/\/127.0.0.1:6443/server: https:\/\/$EC2_PUBLIC_IP:6443/" /home/ec2-user/.kube/config
	echo "Patched kubeconfig to use EC2 public IP: $EC2_PUBLIC_IP"
else
	echo "WARNING: Could not retrieve EC2 public IP for kubeconfig patching."
fi
echo "Kubeconfig is at /home/ec2-user/.kube/config"

# End of script

# Install MetalLB for LoadBalancer support
METALLB_VERSION="v0.13.12"
echo "Installing MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml

# Wait for MetalLB controller to be ready
kubectl wait --namespace metallb-system --for=condition=Available deployment/controller --timeout=120s

# Apply MetalLB address pool manifest
kubectl apply -f /home/ec2-user/metallb-pool.yaml

echo "MetalLB installed and configured."
