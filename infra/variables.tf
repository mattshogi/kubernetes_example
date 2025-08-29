// variables.tf for Terraform variables
variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  description = "Instance type for k3s node (free tier t3.micro)"
  default     = "t3.micro"
}
