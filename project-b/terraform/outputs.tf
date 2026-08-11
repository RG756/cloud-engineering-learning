output "user_pool_id" {
  description = "Cognito User Pool ID (Phase 3でEntra側に登録)"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "app_client_id" {
  description = "App Client ID (Phase 3でEntra側に登録)"
  value       = aws_cognito_user_pool_client.main.id
}

output "hosted_ui_domain" {
  description = "Hosted UI base URL (Phase 3でEntra側のReply URLに使用)"
  value       = "https://${var.cognito_domain_prefix}.auth.${var.aws_region}.amazoncognito.com"
}