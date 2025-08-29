// main.tf for Terraform infrastructure
// This file provisions a k3s node on AWS Free Tier using Amazon Linux 2
// It sets up security, SSH access, and installs k3s via user_data

terraform {
  required_version = ">=1.5"
}

provider "aws" {
  region = var.aws_region
}

// EC2 instance for k3s
resource "aws_instance" "k3s_node" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type   // t3.micro (free tier)
  key_name      = aws_key_pair.k3s.key_name

  vpc_security_group_ids = [aws_security_group.allow_all.id]

  user_data = file("${path.module}/../cluster/k3s_install.sh") // Run k3s install script

  tags = {
    Name = "k3s-node"
  }
}

// Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon Linux 2

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

// SSH key pair for accessing the instance
resource "aws_key_pair" "k3s" {
  key_name   = "k3s-key"
  public_key = file("${path.module}/id_rsa.pub")
}

// Security group allowing all inbound and outbound traffic
resource "aws_security_group" "allow_all" {
  name        = "k3s-allow-all-${random_id.suffix.hex}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_id" "suffix" {
  byte_length = 2
}
