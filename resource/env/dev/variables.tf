variable "env" {
  description = "env name"
  type = "string"
}

variable "project_name" {
  description = "project name"
  type = "string"
}

variable "grafana_host_port" {
  description = "grafana port number"
  type = "integer"
}

variable "app_host_port" {
  description = "app port number"
  type = "integer"
}

variable "alb_listener_port" {
  description = "grafana port number"
  type = "integer"
}

variable "alb_health_check_path" {
  description = "alb health check path"
  type = "string"
}