provider "aws" {
  access_key = "<AWS_ACCESS_KEY_ID>"
  secret_key = "<AWS_ACCESS_SECRET_KEY>"
  region     = "ap-northeast-2"
}

module "alb" {
  source   = "../../modules/alb"
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