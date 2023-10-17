provider "aws" {
  access_key = "<AWS_ACCESS_KEY_ID>"
  secret_key = "<AWS_ACCESS_SECRET_KEY>"
  region     = "ap-northeast-2"
}

module "alb" {
  source                = "../../modules/alb"
  env                   = var.env
  project_name          = var.project_name
  grafana_host_port     = var.grafana_host_port
  app_host_port         = var.app_host_port
  alb_listener_port     = var.alb_listener_port
  alb_health_check_path = var.alb_health_check_path
}

module "ec2" {
  source   = "../../modules/ec2"
}

module "ecs" {
  source   = "../../modules/ecs"
}

module "rds" {
  source   = "../../modules/rds"
}

module "sg" {
  source   = "../../modules/sg"
}

module "vpc" {
  source   = "../../modules/vpc"
}