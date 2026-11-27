# =============================================================================
# IAM Role & Policies for Lambda
# =============================================================================

# Trust policy: Allow Lambda service to assume this role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Project = var.project_name
  }
}

# Policy: Allow Lambda to access DynamoDB table
data "aws_iam_policy_document" "lambda_dynamodb" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
    ]

    resources = [
      aws_dynamodb_table.main.arn,
      aws_dynamodb_table.chat_history.arn,
    ]
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name   = "${var.project_name}-lambda-dynamodb"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_dynamodb.json
}

# Policy: Allow Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy: Allow Lambda to send traces to X-Ray
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# =============================================================================
# IAM Role for API Gateway -> CloudWatch Logs
# =============================================================================
#
# Lambda writes to CloudWatch using its own IAM role.
# API Gateway is a separate service and needs its own role
# to push logs to CloudWatch.

data "aws_iam_policy_document" "apigw_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apigw_cloudwatch" {
  name               = "${var.project_name}-apigw-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_assume_role.json

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "apigw_cloudwatch" {
  role       = aws_iam_role.apigw_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# API Gateway account-level CloudWatch config (one per region)
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.apigw_cloudwatch.arn
}

# Policy: Allow Lambda to invoke Bedrock models
data "aws_iam_policy_document" "lambda_bedrock" {
  statement {
    actions = [
      "bedrock:InvokeModel",
      "bedrock:ApplyGuardrail",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_bedrock" {
  name   = "${var.project_name}-lambda-bedrock"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_bedrock.json
}

# Policy: Allow Lambda to publish custom metrics to CloudWatch
data "aws_iam_policy_document" "lambda_cloudwatch_metrics" {
  statement {
    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_cloudwatch_metrics" {
  name   = "${var.project_name}-lambda-cloudwatch-metrics"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_metrics.json
}
