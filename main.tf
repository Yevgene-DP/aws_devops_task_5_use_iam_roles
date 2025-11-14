# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Variables
variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "public_key" {
  type = string
}

# Отримати останній AMI Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Policy для Grafana
resource "aws_iam_policy" "grafana_policy" {
  name        = "grafana-cloudwatch-policy"
  description = "Policy for Grafana to read CloudWatch metrics and logs"
  policy      = file("${path.module}/grafana-policy.json")
}

# IAM Role для EC2
resource "aws_iam_role" "grafana_role" {
  name = "grafana-ec2-role"

  assume_role_policy = file("${path.module}/grafana-role-assume-policy.json")

  tags = {
    Name = "grafana-role"
  }
}

# Прикріпити політику до ролі
resource "aws_iam_role_policy_attachment" "grafana_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "grafana_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_role.name
}

# Створити ключову пару SSH
resource "aws_key_pair" "grafana_key" {
  key_name   = "grafana-key"
  public_key = var.public_key
}

# Створити EC2 instance з Grafana та IAM Role
resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.grafana_key.key_name
  associate_public_ip_address = true
  user_data              = file("${path.module}/install-grafana.sh")
  iam_instance_profile   = aws_iam_instance_profile.grafana_profile.name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  depends_on = [
    aws_iam_role_policy_attachment.grafana_attachment,
    aws_iam_instance_profile.grafana_profile
  ]
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.grafana.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.grafana.public_ip
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_instance.grafana.public_ip}:3000/"
}

output "grafana_iam_role_arn" {
  description = "ARN of the IAM role for Grafana"
  value       = aws_iam_role.grafana_role.arn
}

output "grafana_iam_role_name" {
  description = "Name of the IAM role for Grafana"
  value       = aws_iam_role.grafana_role.name
}