variable "env" {}
variable "project_name" {}
variable "region" {}
variable "app_host_port" {}
variable "app_container_port" {}
variable "grafana_host_port" {}
variable "grafana_container_port" {}
variable "loki_host_port" {}
variable "loki_container_port_1" {}
variable "loki_container_port_2" {}
variable "loki_container_port_3" {}

variable "ecs_instance_role_arn" {}
variable "ecs_instance_ami" {}
variable "ecs_instance_type" {}
variable "ecs_task_role" {}
variable "ecs_task_role_logging" {}

variable "task_definition_app_cpu" {}
variable "task_definition_app_memory" {}
variable "task_definition_app_container_name" {}
variable "task_definition_app_image" {}
variable "grafana_loki_log_router_image" {}

variable "task_definition_grafana_cpu" {}
variable "task_definition_grafana_memory" {}
variable "task_definition_grafana_container_name" {}
variable "task_definition_grafana_image" {}

variable "task_definition_loki_cpu" {}
variable "task_definition_loki_memory" {}
variable "task_definition_loki_container_name" {}
variable "task_definition_loki_image" {}
variable "loki_dns_name" {}