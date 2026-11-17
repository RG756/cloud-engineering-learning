# =============================================================================
# DynamoDB Table
# =============================================================================

resource "aws_dynamodb_table" "main" {
  name         = "${var.project_name}-items"
  billing_mode = "PAY_PER_REQUEST" # On-demand: no capacity planning needed
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S" # String
  }

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# DynamoDB Table - Chat History (Project F: Bedrock AI)
# =============================================================================
resource "aws_dynamodb_table" "chat_history" {
  name         = "${var.project_name}-chat-history"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "session_id"
  range_key    = "timestamp"

  attribute {
    name = "session_id"
    type = "S" # String
  }

  attribute {
    name = "timestamp"
    type = "S" # String (ISO8601)
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Project = var.project_name
  }
}