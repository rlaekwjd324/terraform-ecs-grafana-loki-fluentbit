output "alb_grafana_arn" {
  value = aws_alb_target_group.terraform-test-alb-grafana.arn
}
output "alb_app_arn" {
  value = aws_alb_target_group.terraform-test-alb-app.arn
}
/* output "alb_loki_arn" {
  value = aws_alb_target_group.terraform-test-alb-loki.arn
} */