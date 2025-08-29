#!/bin/bash
# Automate MetalLB address pool configuration based on EC2 private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')
cat > /home/ec2-user/metallb-pool.yaml <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - ${PRIVATE_IP}-${PRIVATE_IP}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF
kubectl apply -f /home/ec2-user/metallb-pool.yaml
