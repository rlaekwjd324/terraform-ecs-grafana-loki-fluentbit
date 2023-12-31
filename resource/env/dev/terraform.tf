terraform {
  required_version = "~> 1.5.6"

  required_providers {
    aws = "~> 4.0"
    # grafana = {
    #   source = "grafana/grafana"
    #   version = ">= 1.28.2"
    # }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  region     = var.region
}

# provider "grafana" {
#   url = "13.3.0.1:3000"
#   auth = "admin:admin"
# }