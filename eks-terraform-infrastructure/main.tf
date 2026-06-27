# KMS Key for EBS encryption
resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS encryption"
  deletion_window_in_days = 7

  tags = {
    Name        = "${var.project_name}-ebs-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project_name}-ebs-key"
  target_key_id = aws_kms_key.ebs.key_id
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = "ami-0599b6e53ca798bb2"
  instance_type = var.instance_type

  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment
  }
}

# EBS Volume (KMS encrypted)
resource "aws_ebs_volume" "main" {
  availability_zone = aws_instance.main.availability_zone
  size              = var.ebs_volume_size
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs.arn

  tags = {
    Name        = "${var.project_name}-ebs"
    Environment = var.environment
  }
}

# Attach EBS to EC2
resource "aws_volume_attachment" "main" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.main.id
  instance_id = aws_instance.main.id
}# SNS Topic for CloudWatch alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name        = "${var.project_name}-alerts"
    Environment = var.environment
  }
}

# CloudWatch Alarm for EC2 CPU
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilization is too high"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = {
    Name        = "${var.project_name}-cpu-alarm"
    Environment = var.environment
  }
}

# AWS Backup Vault
resource "aws_backup_vault" "main" {
  name = "${var.project_name}-vault"

  tags = {
    Name        = "${var.project_name}-vault"
    Environment = var.environment
  }
}

# AWS Backup Plan
resource "aws_backup_plan" "main" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 17 * * ? *)"

    lifecycle {
      delete_after = 7
    }
  }

  tags = {
    Name        = "${var.project_name}-backup-plan"
    Environment = var.environment
  }
}

# AWS Backup Selection
resource "aws_backup_selection" "main" {
  name         = "${var.project_name}-backup-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    aws_ebs_volume.main.arn
  ]
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Data source for account ID
data "aws_caller_identity" "current" {}