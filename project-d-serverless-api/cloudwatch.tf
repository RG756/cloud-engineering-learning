# =============================================================================
# CloudWatch Log Group - Lambda
# =============================================================================
#
# Lambda automatically sends logs to CloudWatch, but managing the Log Group
# in Terraform gives us control over retention and ensures cleanup on destroy.
# Naming convention: /aws/lambda/{function_name} (AWS-defined)

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 14

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# CloudWatch Log Group - API Gateway Access Logs
# =============================================================================
#
# Separate from Lambda logs:
#   Lambda logs  = what happened inside the function (application logs)
#   API GW logs  = who called which endpoint and when (access logs)

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-api"
  retention_in_days = 14

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# Metric Filter - Detect "ERROR" in Lambda logs
# =============================================================================
#
# Scans Lambda log stream for lines containing "ERROR" (from logger.error())
# and converts each match into a custom CloudWatch metric.
# This metric drives the alarm below.

resource "aws_cloudwatch_log_metric_filter" "lambda_errors" {
  name           = "${var.project_name}-lambda-errors"
  log_group_name = aws_cloudwatch_log_group.lambda.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "${var.project_name}-LambdaErrorCount"
    namespace = "Custom/${var.project_name}"
    value     = "1"
  }
}

# =============================================================================
# SNS Topic - Alarm notification target
# =============================================================================

resource "aws_sns_topic" "alarm" {
  name = "${var.project_name}-alarm-topic"

  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# =============================================================================
# CloudWatch Alarm - Notify on Lambda errors
# =============================================================================
#
# Watches the custom metric from the Metric Filter above.
# Fires when 1+ ERROR occurs within a 5-minute period -> SNS -> email.

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${var.project_name}-LambdaErrorCount"
  namespace           = "Custom/${var.project_name}"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function errors detected"

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = {
    Project = var.project_name
  }
}
