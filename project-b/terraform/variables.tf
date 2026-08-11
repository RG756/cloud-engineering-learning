variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "project-b"
}

variable "cognito_domain_prefix" {
  description = "Unique prefix for Cognito Hosted UI domain (globally unique)"
  type        = string
  default     = "project-b-rg756"
}