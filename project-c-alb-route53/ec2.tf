# ============================================================
# AMI（Amazon Linux 2023 最新版を自動取得）
# ============================================================
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ============================================================
# IAMロール（CloudWatch AgentがメトリクスをPushするために必要）
# ============================================================
resource "aws_iam_role" "ec2_cloudwatch" {
  name = "${var.project_name}-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = { Project = var.project_name }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_cloudwatch" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_cloudwatch.name
}

# ============================================================
# セキュリティグループ（EC2用）
# ============================================================
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "EC2 security group - allows HTTP from ALB only"
  vpc_id      = aws_vpc.main.id

  # ALBからのHTTP（IPv4）
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # ALBからのHTTP（IPv6）
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.project_name}-ec2-sg", Project = var.project_name }
}

# ============================================================
# セキュリティグループ（ALB用）※ ec2.tf で先に定義
# ============================================================
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB security group - allows HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg", Project = var.project_name }
}

# ============================================================
# EC2 × 2
# ============================================================
resource "aws_instance" "web" {
  count                  = 2
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_cloudwatch.name
  ipv6_address_count     = 1

  user_data = <<-EOF
    #!/bin/bash
    # nginx インストール＆起動
    dnf install -y nginx
    systemctl enable nginx
    systemctl start nginx

    # どのサーバーに届いたか分かるようにHTMLを書き換え
    echo "<h1>Hello from Web Server ${count.index + 1}</h1>" > /usr/share/nginx/html/index.html

    # CloudWatch Agent インストール＆起動
    dnf install -y amazon-cloudwatch-agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s -c default
  EOF

  tags = {
    Name    = "${var.project_name}-web-${count.index + 1}"
    Project = var.project_name
  }
}