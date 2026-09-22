# =============================================================================
# Lambda Function
# =============================================================================

# Package Python code into a zip for deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "api" {
  function_name    = "${var.project_name}-api"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "python3.12"
  timeout          = 10
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.main.name
      LOG_LEVEL  = "INFO"
    }
  }

  tags = {
    Project = var.project_name
  }

  tracing_config {
    mode = "Active"
  }
}

# =============================================================================
# Lambda - Slack Notifier
# =============================================================================
#
# SNS → Lambda → Slack Webhook の通知専用Lambda
# CloudWatchアラームの状態変化を日英バイリンガルでSlackに送信する

data "archive_file" "slack_notifier_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/slack_notifier.py"
  output_path = "${path.module}/slack_notifier.zip"
}

resource "aws_lambda_function" "slack_notifier" {
  filename         = data.archive_file.slack_notifier_zip.output_path
  function_name    = "${var.project_name}-slack-notifier"
  role             = aws_iam_role.lambda_role.arn
  handler          = "slack_notifier.handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.slack_notifier_zip.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_lambda_permission" "sns_slack" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm.arn
}

resource "aws_sns_topic_subscription" "slack" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn
}