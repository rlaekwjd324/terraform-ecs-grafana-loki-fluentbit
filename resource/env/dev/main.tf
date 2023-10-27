module "alb" {
  source                = "../../modules/alb"

  vpc_id                = module.vpc.vpc_id
  public_subnet_1_id    = module.vpc.public_subnet_1_id
  public_subnet_2_id    = module.vpc.public_subnet_2_id
  alb_sg_id             = module.sg.alb_sg_id

  env                   = var.env
  project_name          = var.project_name
  grafana_host_port     = var.grafana_host_port
  app_host_port         = var.app_host_port
  alb_listener_port     = var.alb_listener_port
  alb_health_check_path = var.alb_health_check_path

  depends_on = [
    module.vpc
  ]
}

module "ec2" {
  source                      = "../../modules/ec2"

  public_subnet_1_id          = module.vpc.public_subnet_1_id
  public_ec2_sg_id            = module.sg.public_ec2_sg_id

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

  private_subnet_3_id                     = module.vpc.private_subnet_3_id
  private_ec2_sg_id                       = module.sg.private_ec2_sg_id
  alb_grafana_arn                         = module.alb.alb_grafana_arn
  alb_app_arn                             = module.alb.alb_app_arn
  /* alb_loki_arn                            = module.alb.alb_loki_arn */
  
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

  ecs_instance_role_arn                   = var.ecs_instance_role_arn
  ecs_instance_role_profile_arn           = var.ecs_instance_role_profile_arn
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
    module.vpc,
    module.alb
  ]
}

module "rds" {
  source                = "../../modules/rds"

  rds_sg_id             = module.sg.rds_sg_id
  rds_subnet_group_id   = module.vpc.rds_subnet_group_id
  
  env                   = var.env
  project_name          = var.project_name
  region                = var.region

  rds_paramgroup_family = var.rds_paramgroup_family
  rds_engine            = var.rds_engine
  rds_engine_version    = var.rds_engine_version
  rds_instance_class    = var.rds_instance_class
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

  vpc_id                     = module.vpc.vpc_id

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

module "cicd" {
  source                     = "../../modules/cicd"

  account_id                 = var.account_id
  aws_access_key_id          = var.aws_access_key_id
  aws_access_secret_key      = var.aws_access_secret_key
  project_name               = var.project_name
  region                     = var.region
  env                        = var.env
  github_account_name        = var.github_account_name
  github_token               = var.github_token
  github_repository          = var.github_repository
  github_branch              = var.github_branch
  imagedefinitions_path      = var.imagedefinitions_path

  depends_on = [
    module.vpc,
    module.alb,
    module.ec2,
    module.ecs,
    module.rds,
    module.sg
  ]
}