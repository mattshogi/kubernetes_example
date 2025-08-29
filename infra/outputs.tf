// outputs.tf for Terraform outputs

output "instance_public_ip" {
  value       = aws_instance.k3s_node[0].public_ip
  description = "Public IP of the k3s node"
}

output "kubeconfig" {
  value       = file("${path.module}/../cluster/kubeconfig.tpl")
  description = "Kubeconfig template for accessing the cluster"
}
