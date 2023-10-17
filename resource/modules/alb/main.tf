/* alb 설정 */
resource "aws_alb" "terraform-test-alb" {
  name            = "${var.env}-${var.project_name}-alb"
  internal        = false
  security_groups = [aws_security_group.terraform-test-alb.id]
  subnets         = [var.public_subnet_1_id, var.public_subnet_2_id]

  lifecycle { create_before_destroy = true }
}

resource "aws_alb_target_group" "terraform-test-alb-grafana" {
  name     = "${var.env}-${var.project_name}-tg-grafana"
  port     = var.grafana_host_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_target_group" "terraform-test-alb-app" {
  name     = "${var.env}-${var.project_name}-tg-app"
  port     = var.app_host_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "${var.alb_health_check_path}"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_alb_listener" "terraform-test-alb" {
  load_balancer_arn = aws_alb.terraform-test-alb.arn
  port              = var.alb_listener_port
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
  listener_arn = aws_alb_listener.terraform-test-alb.arn

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

resource "aws_alb_listener_rule" "terraform-test-alb-grafana" {
  listener_arn = aws_alb_listener.terraform-test-alb.arn

  condition {
    path_pattern {
      values = ["/*/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.terraform-test-alb-grafana.arn
  }
}

# resource "aws_alb_listener_rule" "terraform-test-alb-loki" {
#   listener_arn = aws_alb_listener.terraform-test-alb.arn

#   condition {
#     query_string {
#       key = "page"
#       value = "loki"
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.terraform-test-alb-loki.arn
#   }
# }

resource "aws_alb_listener_rule" "terraform-test-alb-app" {
  listener_arn = aws_alb_listener.terraform-test-alb.arn

  condition {
    query_string {
      key = "page"
      value = "app"
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.terraform-test-alb-app.arn
  }
}