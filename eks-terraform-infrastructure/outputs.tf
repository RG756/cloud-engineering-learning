output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.main.public_ip
}

output "ebs_volume_id" {
  description = "EBS volume ID"
  value       = aws_ebs_volume.main.id
}

output "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  value       = aws_kms_key.ebs.arn
}