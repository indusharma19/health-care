terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
}

# Step 1: Specify the VPC, subnet, and security group IDs directly

variable "vpc_id" {
  default = "vpc-0372326625a51609c"  # Replace with your VPC ID
}

variable "subnet_id" {
  default = "subnet-04ab20917f2bb54a8"  # Replace with your Subnet ID
}

variable "security_group_id" {
  default = "sg-0621fbf4cefe4b2d0"  # Replace with your Security Group ID
}

variable "internet_gateway_id" {
  default = "igw-06a9d084a0b52702b"  # Replace with your Internet Gateway ID
}

variable "route_table_id" {
  default = "rtb-0d6c31487a9bbe4b6"  # Replace with your Route Table ID
}

variable "key_pair_name" {
  default = "linux"  # Replace with the key pair name used by terra-infra instance
}


resource "aws_instance" "test1" {
  ami           = "ami-0e04bcbe83a83792e"
  instance_type = "t2.medium"
  key_name      = var.key_pair_name  # Replace with your SSH key name
  subnet_id     = var.subnet_id
  
  root_block_device {
  volume_size = 12  # Set the size of the root volume
  }

  vpc_security_group_ids = [var.security_group_id]  # Reuse the existing Security Group
  tags = {
    Name = "test1"
  }
}

resource "aws_instance" "prod" {
  ami           = "ami-0e04bcbe83a83792e"
  instance_type = "t2.micro"
  key_name      = var.key_pair_name  # Replace with your SSH key name
  subnet_id     = var.subnet_id

  root_block_device {
  volume_size = 8  # Set the size of the root volume
  }

  vpc_security_group_ids = [var.security_group_id]  # Reuse the existing Security Group
  tags = {
    Name = "prod"
  }
}

# Step 3: Output the public IPs of the new instances (optional)
output "test_public_ip" {
  value = aws_instance.test1.public_ip
}

output "instance2_public_ip" {
  value = aws_instance.prod.public_ip
}
