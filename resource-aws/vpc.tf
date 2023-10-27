module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-vpc"
  cidr = "10.5.0.0/16"

  azs             = ["${var.region}a", "${var.region}c"]

  public_subnets  = ["10.5.1.0/24", "10.5.2.0/24"]
  private_subnets = ["10.5.3.0/24"]
  public_subnets  = ["10.5.4.0/24", "10.5.5.0/24"]

  create_database_subnet_group = true
  
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}