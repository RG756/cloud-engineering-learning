# ============================================================
# SNSトピック（アラーム通知の送信先）
# ============================================================
resource "aws_sns_topic" "alarm" {
  name = "${var.project_name}-alarm-topic"

  tags = { Project = var.project_name }
}

# メールアドレスをSNSに登録
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ============================================================
# CloudWatch Alarm① EC2 CPU使用率（2台分）
# ============================================================
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = 2
  alarm_name          = "${var.project_name}-cpu-high-web-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "EC2 CPU使用率が70%を超えました"

  dimensions = {
    InstanceId = aws_instance.web[count.index].id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = { Project = var.project_name }
}

# ============================================================
# CloudWatch Alarm② ALB ターゲット異常数
# ============================================================
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "ALBのUnhealthyホストが1台以上あります"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.web.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]

  tags = { Project = var.project_name }
}