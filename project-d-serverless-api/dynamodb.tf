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
