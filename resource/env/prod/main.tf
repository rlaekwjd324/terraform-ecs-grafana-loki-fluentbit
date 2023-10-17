provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  region     = var.region
}

module "alb" {
  source                = "../../modules/alb"

  env                   = var.env
  project_name          = var.project_name
  grafana_host_port     = var.grafana_host_port
  app_host_port         = var.app_host_port
  alb_listener_port     = var.alb_listener_port
  alb_health_check_path = var.alb_health_check_path

  depends_on = [
    module.vpc,
    module.ecs
  ]
}

module "ec2" {
  source                      = "../../modules/ec2"

  env                         = var.env
  project_name                = var.project_name
  bastion_host_instance_ami   = var.bastion_host_instance_ami
  bastion_host_instance_type  = var.bastion_host_instance_type

  depends_on = [
    module.vpc
  ]
}

module "ecs" {
  source                                  = "../../modules/ecs"
  
  env                                     = var.env
  project_name                            = var.project_name
  region                                  = var.region
  app_host_port                           = var.app_host_port
  app_container_port                      = var.app_container_port
  grafana_host_port                       = var.grafana_host_port
  grafana_container_port                  = var.grafana_container_port
  loki_host_port                          = var.loki_host_port
  loki_container_port_1                   = var.loki_container_port_1
  loki_container_port_2                   = var.loki_container_port_2
  loki_container_port_3                   = var.loki_container_port_3

  ecs_task_role                           = var.ecs_task_role
  ecs_instance_role_arn                   = var.ecs_instance_role_arn
  ecs_instance_ami                        = var.ecs_instance_ami
  ecs_instance_type                       = var.ecs_instance_type
  ecs_task_role                           = var.ecs_task_role
  ecs_task_role_logging                   = var.ecs_task_role_logging

  task_definition_app_cpu                 = var.task_definition_app_cpu
  task_definition_app_memory              = var.task_definition_app_memory
  task_definition_app_container_name      = var.task_definition_app_container_name
  task_definition_app_image               = var.task_definition_app_image
  grafana_loki_log_router_image           = var.grafana_loki_log_router_image

  task_definition_grafana_cpu             = var.task_definition_grafana_cpu
  task_definition_grafana_memory          = var.task_definition_grafana_memory
  task_definition_grafana_container_name  = var.task_definition_grafana_container_name
  task_definition_grafana_image           = var.task_definition_grafana_image

  task_definition_loki_cpu                = var.task_definition_loki_cpu
  task_definition_loki_memory             = var.task_definition_loki_memory
  task_definition_loki_container_name     = var.task_definition_loki_container_name
  task_definition_loki_image              = var.task_definition_loki_image
  loki_dns_name                           = var.loki_dns_name

  depends_on = [
    module.vpc
  ]
}

module "rds" {
  source                = "../../modules/rds"

  env                   = var.env
  project_name          = var.project_name
  region                = var.region

  rds_paramgroup_family = var.rds_paramgroup_family
  rds_engine_version    = var.rds_engine_version
  rds_instance_class    = var.rds_instance_class
  rds_option_group_name = var.rds_option_group_name
  rds_storage_type      = var.rds_storage_type
  rds_db_name           = var.rds_db_name
  rds_username          = var.rds_username
  rds_password          = var.rds_password

  depends_on = [
    module.vpc,
    module.sg
  ]
}

module "sg" {
  source                     = "../../modules/sg"

  env                        = var.env
  project_name               = var.project_name
  vpc_ssh_ingress_cidr_block = var.vpc_ssh_ingress_cidr_block
  
  depends_on = [
    module.vpc
  ]
}

module "vpc" {
  source                      = "../../modules/vpc"

  env                         = var.env
  project_name                = var.project_name
  region                      = var.region

  vpc_cidr_bolock             = var.vpc_cidr_bolock
  public_subnet_1_cidr_block  = var.public_subnet_1_cidr_block
  public_subnet_5_cidr_block  = var.public_subnet_5_cidr_block
  private_subnet_3_cidr_block = var.private_subnet_3_cidr_block
  public_subnet_2_cidr_block  = var.public_subnet_2_cidr_block
  public_subnet_6_cidr_block  = var.public_subnet_6_cidr_block
}