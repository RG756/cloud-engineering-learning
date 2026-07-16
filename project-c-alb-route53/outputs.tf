# ============================================================
# 確認用アウトプット
# ============================================================

output "alb_dns_name" {
  description = "ALBのDNS名（直接アクセス用）"
  value       = aws_lb.main.dns_name
}

output "website_url" {
  description = "WebサイトURL（Route 53経由）"
  value       = "http://${var.subdomain}.${var.domain_name}"
}

output "ec2_instance_ids" {
  description = "EC2インスタンスID（×2）"
  value       = aws_instance.web[*].id
}

output "ec2_public_ips" {
  description = "EC2パブリックIP（×2）"
  value       = aws_instance.web[*].public_ip
}

output "ec2_ipv6_addresses" {
  description = "EC2 IPv6アドレス（×2）"
  value       = aws_instance.web[*].ipv6_addresses
}

output "route53_zone_id" {
  description = "Route 53 ホストゾーンID"
  value       = data.aws_route53_zone.main.zone_id
}

output "sns_topic_arn" {
  description = "SNSトピックARN"
  value       = aws_sns_topic.alarm.arn
}