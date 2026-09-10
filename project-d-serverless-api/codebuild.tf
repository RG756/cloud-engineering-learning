# CodeBuild用IAMロール
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-project-d-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })
}

# CodeBuildプロジェクト
resource "aws_codebuild_project" "project_d" {
  name           = "project-d-build"
  description    = "CI build and test for Project D serverless API"
  service_role   = aws_iam_role.codebuild_role.arn
  build_timeout  = 10
  source_version = "e-phase2-codebuild-deploy"

  source {
    type            = "GITHUB"
    location        = "https://github.com/RG756/cloud-engineering-learning"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
    
    git_submodules_config {
      fetch_submodules = false
    }
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}