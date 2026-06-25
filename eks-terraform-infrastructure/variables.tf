variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "eks-terraform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}