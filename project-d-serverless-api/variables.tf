# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "project-d"
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  sensitive   = true
}
