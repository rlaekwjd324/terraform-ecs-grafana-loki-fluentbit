variable "env" {
  description = "env name"
  type = "string"
}

variable "project_name" {
  description = "project name"
  type = "string"
}

variable "region" {
  description = "region"
  type = "string"
}

variable "app_host_port" {
  description = "app port number"
  type = "integer"
}

variable "app_container_port" {
  description = "app container number"
  type = "integer"
}

variable "grafana_host_port" {
  description = "grafana port number"
  type = "integer"
}

variable "grafana_container_port" {
  description = "grafana container number"
  type = "integer"
}

variable "loki_host_port" {
  description = "loki port number"
  type = "integer"
}

variable "loki_container_port_1" {
  description = "loki container number 1"
  type = "integer"
}

variable "loki_container_port_2" {
  description = "loki container number 2"
  type = "integer"
}

variable "loki_container_port_3" {
  description = "loki container number 3"
  type = "integer"
}

# alb
variable "alb_listener_port" {
  description = "grafana port number"
  type = "integer"
}

variable "alb_health_check_path" {
  description = "alb health check path"
  type = "string"
}

#ec2
variable "bastion_host_instance_ami" {
  description = "bastion host instance ami"
  type = "string"
}

variable "bastion_host_instance_type" {
  description = "bastion host instance type"
  type = "string"
}

# ecs
variable "ecs_task_role" {
  description = "ecs task role"
  type = "string"
}

variable "ecs_instance_role_arn" {
  description = "ecs instance role arn"
  type = "string"
}

variable "ecs_instance_ami" {
  description = "ecs instance ami"
  type = "string"
}

variable "ecs_instance_type" {
  description = "ecs instance type"
  type = "string"
}

variable "ecs_task_role" {
  description = "ecs task role"
  type = "string"
}

variable "ecs_task_role_logging" {
  description = "ecs task role logging"
  type = "string"
}

variable "task_definition_app_cpu" {
  description = "task definition app cpu"
  type = "integer"
}

variable "task_definition_app_memory" {
  description = "task definition app memory"
  type = "integer"
}

variable "task_definition_app_container_name" {
  description = "task definition app container name"
  type = "string"
}

variable "task_definition_app_image" {
  description = "task definition app image"
  type = "string"
}

variable "grafana_loki_log_router_image" {
  description = "grafana loki log router image"
  type = "string"
}

variable "task_definition_grafana_cpu" {
  description = "task definition grafana cpu"
  type = "integer"
}

variable "task_definition_grafana_memory" {
  description = "task definition grafana memory"
  type = "integer"
}

variable "task_definition_grafana_container_name" {
  description = "task definition grafana container name"
  type = "string"
}

variable "task_definition_grafana_image" {
  description = "task definition grafana image"
  type = "string"
}

variable "task_definition_loki_cpu" {
  description = "task definition loki cpu"
  type = "integer"
}

variable "task_definition_loki_memory" {
  description = "task definition loki memory"
  type = "integer"
}

variable "task_definition_loki_container_name" {
  description = "task definition loki container name"
  type = "string"
}

variable "task_definition_loki_image" {
  description = "task definition loki image"
  type = "string"
}

variable "loki_dns_name" {
  description = "loki dns name"
  type = "string"
}