/* alb 설정 */
resource "aws_alb" "dory-terraform-test-alb" {
  name            = "dory-terraform-test-alb"
  internal        = false
  security_groups = [aws_security_group.dory-terraform-test-alb.id]
  subnets         = [aws_subnet.dory-terraform-test-public-subnet-1.id, aws_subnet.dory-terraform-test-public-subnet-2.id]

  lifecycle { create_before_destroy = true }
}

resource "aws_alb_target_group" "dory-terraform-test-alb-grafana" {
  name     = "dory-terraform-test-tg-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.dory-terraform-test-vpc.id

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_target_group" "dory-terraform-test-alb-app" {
  name     = "dory-terraform-test-tg-app"
  port     = 3033
  protocol = "HTTP"
  vpc_id   = aws_vpc.dory-terraform-test-vpc.id

  health_check {
    interval            = 30
    path                = "/health/check"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_target_group" "dory-terraform-test-alb-loki" {
  name     = "dory-terraform-test-tg-loki"
  port     = 3100
  protocol = "HTTP"
  vpc_id   = aws_vpc.dory-terraform-test-vpc.id

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "dory-terraform-test-alb" {
  load_balancer_arn = aws_alb.dory-terraform-test-alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_alb_listener.dory-terraform-test-alb.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    http_header {
      http_header_name = "X-Forwarded-For"
      values           = ["192.168.1.*"]
    }
  }
}

resource "aws_alb_listener_rule" "dory-terraform-test-alb-grafana" {
  listener_arn = aws_alb_listener.dory-terraform-test-alb.arn

  condition {
    path_pattern {
      values = ["/*/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.dory-terraform-test-alb-grafana.arn
  }
}

resource "aws_alb_listener_rule" "dory-terraform-test-alb-loki" {
  listener_arn = aws_alb_listener.dory-terraform-test-alb.arn

  condition {
    query_string {
      key = "page"
      value = "loki"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.dory-terraform-test-alb-loki.arn
  }
}

resource "aws_alb_listener_rule" "dory-terraform-test-alb-app" {
  listener_arn = aws_alb_listener.dory-terraform-test-alb.arn

  condition {
    query_string {
      key = "page"
      value = "app"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.dory-terraform-test-alb-app.arn
  }
}