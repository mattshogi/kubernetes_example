// outputs.tf for Terraform outputs

output "instance_public_ip" {
  value       = aws_instance.k3s_node[0].public_ip
  description = "Public IP of the k3s node"
}

output "kubeconfig" {
  value       = file("${path.module}/../cluster/kubeconfig.tpl")
  description = "Kubeconfig template for accessing the cluster"
}

output "security_group_id" {
  value = aws_security_group.allow_all.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}

output "public_acl_id" {
  value = aws_network_acl.public_acl.id
}

output "instance_public_ip" {
  value = aws_instance.k3s_node.public_ip
}
