// main.tf for Terraform infrastructure
// This file provisions a k3s node on AWS Free Tier using Amazon Linux 2
// It sets up security, SSH access, and installs k3s via user_data

terraform {
  required_version = ">=1.5"
}

provider "aws" {
  region = var.aws_region
}

// VPC for the infrastructure
resource "aws_vpc" "main" {
  cidr_block              = "10.0.0.0/16"
  enable_dns_support      = true
  enable_dns_hostnames    = true

  tags = {
    Name        = "k3s-vpc"
    Project     = "kubernetes_example"
    Environment = "dev"
  }
}

// Internet Gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "k3s-igw"
    Project     = "kubernetes_example"
    Environment = "dev"
  }
}

// Public subnet for the EC2 instance
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "k3s-public-subnet"
    Project     = "kubernetes_example"
    Environment = "dev"
  }
}

data "aws_availability_zones" "available" {}

// Route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "k3s-public-rt"
    Project     = "kubernetes_example"
    Environment = "dev"
  }
}

// Route table association for the public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

// Network ACL for the public subnet
resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  subnet_ids = [aws_subnet.public.id]
  tags = {
    Name = "k3s-public-acl"
  }
}

// Security group allowing all inbound and outbound traffic
resource "aws_security_group" "allow_all" {
  name        = "k3s-sg"
  description = "Allow SSH, ICMP, HTTP, and app traffic for k3s demo"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow app port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "k3s-sg"
  }
}

// EC2 instance for k3s
resource "aws_instance" "k3s_node" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type   // t3.micro (free tier)
  key_name               = aws_key_pair.k3s.key_name
  count                  = 1
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/../cluster/k3s_install.sh") // Run k3s install script

  tags = {
    Name        = "k3s-node"
    Project     = "kubernetes_example"
    Environment = "dev"
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
  key_name   = "k3s-key-${random_id.suffix.hex}"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "random_id" "suffix" {
  byte_length = 2
}
