# --- Cognito User Pool ---
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  # Email attribute (SAML attribute mapping で使用)
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  auto_verified_attributes = ["email"]

  tags = {
    Project = var.project_name
    Phase   = "phase2"
  }
}

# --- App Client ---
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.project_name}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth2 Authorization Code flow（Phase 3でEntra IDを追加）
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  # Phase 3で正式URLに更新
  callback_urls = ["https://example.com/callback"]
  logout_urls   = ["https://example.com/logout"]

  supported_identity_providers = ["COGNITO"]

  generate_secret = false
}

# --- Hosted UI Domain ---
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}