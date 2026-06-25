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
}