variable "aws_access_key_id" {
  description = "aws access key id"
  type = string
}

variable "aws_access_secret_key" {
  description = "aws access secret key"
  type = string
}

variable "env" {
  description = "env name"
  type = string
}

variable "project_name" {
  description = "project name"
  type = string
}

variable "region" {
  description = "region"
  type = string
}

variable "app_host_port" {
  description = "app port number"
  type = number
}

variable "app_container_port" {
  description = "app container number"
  type = number
}

variable "grafana_host_port" {
  description = "grafana port number"
  type = number
}

variable "grafana_container_port" {
  description = "grafana container number"
  type = number
}

variable "loki_host_port" {
  description = "loki port number"
  type = number
}

variable "loki_container_port_1" {
  description = "loki container number 1"
  type = number
}

variable "loki_container_port_2" {
  description = "loki container number 2"
  type = number
}

variable "loki_container_port_3" {
  description = "loki container number 3"
  type = number
}

# alb
variable "alb_listener_port" {
  description = "grafana port number"
  type = number
}

variable "alb_health_check_path" {
  description = "alb health check path"
  type = string
}

#ec2
variable "bastion_host_instance_ami" {
  description = "bastion host instance ami"
  type = string
}

variable "bastion_host_instance_type" {
  description = "bastion host instance type"
  type = string
}

# ecs
variable "ecs_instance_role_arn" {
  description = "ecs instance role arn"
  type = string
}

variable "ecs_instance_role_profile_arn" {
  description = "ecs instance role arn"
  type = string
}

variable "ecs_instance_ami" {
  description = "ecs instance ami"
  type = string
}

variable "ecs_instance_type" {
  description = "ecs instance type"
  type = string
}

variable "ecs_task_role" {
  description = "ecs task role"
  type = string
}

variable "ecs_task_role_logging" {
  description = "ecs task role logging"
  type = string
}

variable "task_definition_app_cpu" {
  description = "task definition app cpu"
  type = number
}

variable "task_definition_app_memory" {
  description = "task definition app memory"
  type = number
}

variable "task_definition_app_container_name" {
  description = "task definition app container name"
  type = string
}

variable "task_definition_app_image" {
  description = "task definition app image"
  type = string
}

variable "grafana_loki_log_router_image" {
  description = "grafana loki log router image"
  type = string
}

variable "task_definition_grafana_cpu" {
  description = "task definition grafana cpu"
  type = number
}

variable "task_definition_grafana_memory" {
  description = "task definition grafana memory"
  type = number
}

variable "task_definition_grafana_container_name" {
  description = "task definition grafana container name"
  type = string
}

variable "task_definition_grafana_image" {
  description = "task definition grafana image"
  type = string
}

variable "task_definition_loki_cpu" {
  description = "task definition loki cpu"
  type = number
}

variable "task_definition_loki_memory" {
  description = "task definition loki memory"
  type = number
}

variable "task_definition_loki_container_name" {
  description = "task definition loki container name"
  type = string
}

variable "task_definition_loki_image" {
  description = "task definition loki image"
  type = string
}

variable "loki_dns_name" {
  description = "loki dns name"
  type = string
}

# rds
variable "rds_paramgroup_family" {
  description = "rds parameter group family"
  type = string
}

variable "rds_engine" {
  description = "rds engine"
  type = string
}

variable "rds_engine_version" {
  description = "rds engine version"
  type = string
}

variable "rds_instance_class" {
  description = "rds instance class"
  type = string
}

variable "rds_storage_type" {
  description = "rds storage type"
  type = string
}

variable "rds_db_name" {
  description = "rds db name"
  type = string
}

variable "rds_username" {
  description = "rds user name"
  type = string
}

variable "rds_password" {
  description = "rds password"
  type = string
}

# sg
variable "vpc_ssh_ingress_cidr_block" {
  description = "vpc ssh ingress cidr block"
  type = string
}

# vpc
variable "vpc_cidr_bolock" {
  description = "vpc cidr bolock"
  type = string
}

variable "public_subnet_1_cidr_block" {
  description = "public subnet 1 cidr block"
  type = string
}

variable "public_subnet_5_cidr_block" {
  description = "public subnet 5 cidr block"
  type = string
}

variable "private_subnet_3_cidr_block" {
  description = "private subnet 3 cidr block"
  type = string
}

variable "public_subnet_2_cidr_block" {
  description = "public subnet 2 cidr block"
  type = string
}

variable "public_subnet_6_cidr_block" {
  description = "public subnet 6 cidr block"
  type = string
}

# ci/cd
variable "account_id" {
  description = "account id"
  type = string
}

variable "github_account_name" {
  description = "github account name"
  type = string
}
variable "github_token" {
  description = "github token"
  type = string
}
variable "github_repository" {
  description = "github repository"
  type = string
}
variable "github_branch" {
  description = "github branch"
  type = string
}

variable "imagedefinitions_path" {
  description = "imagedefinitions path"
  type = string
}