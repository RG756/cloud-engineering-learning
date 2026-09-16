# CodeDeploy用IAMロール
resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-project-d-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForLambda"
}

# CodeDeployアプリケーション
resource "aws_codedeploy_app" "project_d" {
  name             = "project-d-deploy"
  compute_platform = "Lambda"
}

# CodeDeployデプロイグループ
resource "aws_codedeploy_deployment_group" "project_d" {
  app_name               = aws_codedeploy_app.project_d.name
  deployment_group_name  = "project-d-deployment-group"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}