# ============================================================
# ALB（Application Load Balancer）- dualstack（IPv4 + IPv6）
# ============================================================
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  # dualstack = IPv4 + IPv6 両対応
  ip_address_type = "dualstack"

  tags = {
    Name    = "${var.project_name}-alb"
    Project = var.project_name
  }
}

# ============================================================
# ターゲットグループ（ALBがリクエストを転送する先）
# ============================================================
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # ヘルスチェック設定
  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name    = "${var.project_name}-tg"
    Project = var.project_name
  }
}

# ============================================================
# ターゲット登録（EC2 × 2 をターゲットグループに追加）
# ============================================================
resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# ============================================================
# リスナー（HTTP:80 → ターゲットグループへ転送）
# ============================================================
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}