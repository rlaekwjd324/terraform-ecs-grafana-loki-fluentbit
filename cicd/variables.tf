#--------------------------------------------------------------
# Variable Settings
#--------------------------------------------------------------
#AWS Settings
variable "account_id" {}

variable "aws_access_key_id" {}
variable "aws_access_secret_key" {}
variable "project_name" {}
variable "region" {}

variable "artifact_bucket_name" {}

variable "github_account_name" {}
variable "github_token" {}
variable "github_repository" {}
variable "github_branch" {}


variable "codebuild_name" {}
variable "buildspec_path" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "imagedefinitions_path" {}

variable "slack_webhook" {}