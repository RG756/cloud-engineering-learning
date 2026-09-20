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

# =============================================================================
# CloudWatch Alarm - API Gateway Latency
# =============================================================================
#
# Fires when average response time exceeds 3 seconds over 5 minutes.
# Slow API = bad UX even if no errors are occurring.

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${var.project_name}-api-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Average"
  threshold           = 3000
  alarm_description   = "API Gateway latency exceeded 3 seconds"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.api.name
    Stage   = aws_api_gateway_stage.prod.stage_name
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# CloudWatch Alarm - Lambda Duration
# =============================================================================
#
# Fires when average execution time exceeds 10 seconds over 5 minutes.
# Lambda timeout is typically 15-30s, so 10s is an early warning.

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 10000
  alarm_description   = "Lambda execution time exceeded 10 seconds"

  dimensions = {
    FunctionName = aws_lambda_function.api.function_name
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# CloudWatch Alarm - DynamoDB System Errors
# =============================================================================
#
# Fires when DynamoDB returns system errors (5xx).
# Distinct from Lambda errors - catches DB-layer problems independently.

resource "aws_cloudwatch_metric_alarm" "dynamodb_errors" {
  alarm_name          = "${var.project_name}-dynamodb-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DynamoDB system errors detected"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = {
    Project = var.project_name
  }
}

# =============================================================================
# CloudWatch Dashboard
# =============================================================================
#
# Single-pane view of the entire stack's health.
# Covers Lambda, API Gateway, and DynamoDB in one screen.

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Error Count"
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.api.function_name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Duration (ms)"
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.api.function_name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway - Latency (ms)"
          view   = "timeSeries"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", aws_api_gateway_rest_api.api.name, "Stage", aws_api_gateway_stage.prod.stage_name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "API Gateway - 4xx / 5xx Errors"
          view   = "timeSeries"
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiName", aws_api_gateway_rest_api.api.name, "Stage", aws_api_gateway_stage.prod.stage_name],
            ["AWS/ApiGateway", "5XXError", "ApiName", aws_api_gateway_rest_api.api.name, "Stage", aws_api_gateway_stage.prod.stage_name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB - Read/Write Capacity"
          view   = "timeSeries"
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", aws_dynamodb_table.main.name],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.main.name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "DynamoDB - System Errors"
          view   = "timeSeries"
          metrics = [
            ["AWS/DynamoDB", "SystemErrors", "TableName", aws_dynamodb_table.main.name]
          ]
          period = 300
          region = "ap-northeast-1"
        }
      }
    ]
  })
}