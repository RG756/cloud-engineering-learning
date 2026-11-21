# ============================================================
# Bedrock Guardrails - Phase 3
# ============================================================

resource "aws_bedrock_guardrail" "project_f" {
  name                      = "${var.project_name}-guardrail"
  description               = "Project F用ガードレール - 有害コンテンツ・機密情報フィルタリング"
  blocked_input_messaging   = "申し訳ありません。そのご質問にはお答えできません。別の内容でお試しください。"
  blocked_outputs_messaging = "申し訳ありません。その回答はお伝えできません。別の内容でお試しください。"

  # 有害コンテンツフィルター
  content_policy_config {
    filters_config {
      type            = "HATE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type            = "INSULTS"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "SEXUAL"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type            = "VIOLENCE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
    filters_config {
      type            = "MISCONDUCT"
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
    }
    filters_config {
      type            = "PROMPT_ATTACK"
      input_strength  = "HIGH"
      output_strength = "NONE"
    }
  }

  # 機密情報マスキング（PII）
  sensitive_information_policy_config {
    pii_entities_config {
      type   = "EMAIL"
      action = "ANONYMIZE"
    }
    pii_entities_config {
      type   = "PHONE"
      action = "ANONYMIZE"
    }
    pii_entities_config {
      type   = "NAME"
      action = "ANONYMIZE"
    }
    pii_entities_config {
      type   = "CREDIT_DEBIT_CARD_NUMBER"
      action = "BLOCK"
    }
  }

  tags = {
    Project = var.project_name
    Phase   = "phase3"
    Env     = "dev"
  }
}

# Guardrailのバージョン固定（本番利用に必須）
resource "aws_bedrock_guardrail_version" "project_f" {
  guardrail_arn = aws_bedrock_guardrail.project_f.guardrail_arn
  description   = "Phase 3 initial version"
}

# Lambda環境変数から参照できるようoutputに出しておく
output "guardrail_id" {
  value = aws_bedrock_guardrail.project_f.guardrail_id
}

output "guardrail_version" {
  value = aws_bedrock_guardrail_version.project_f.version
}
