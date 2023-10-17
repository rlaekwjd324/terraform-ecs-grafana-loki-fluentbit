terraform {
  required_version = "~> 1.5.6"

  required_providers {
    aws = "~> 4.0"
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_access_secret_key
  region     = var.region
}