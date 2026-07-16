# ============================================================
# 変数定義
# ============================================================

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックスに使用）"
  type        = string
  default     = "project-c"
}

variable "domain_name" {
  description = "Route 53で登録したドメイン名"
  type        = string
}

variable "subdomain" {
  description = "ALBに紐付けるサブドメイン"
  type        = string
  default     = "web"
}

variable "vpc_cidr" {
  description = "VPCのIPv4 CIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "パブリックサブネットのCIDR（ALB用、2AZ分）"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  description = "EC2インスタンスタイプ"
  type        = string
  default     = "t3.micro"
}

variable "alarm_email" {
  description = "CloudWatchアラーム通知先メールアドレス"
  type        = string
}