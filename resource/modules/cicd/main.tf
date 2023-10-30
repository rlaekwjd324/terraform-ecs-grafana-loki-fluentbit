#--------------------------------------------------------------
# S3 bucket Setting
#--------------------------------------------------------------
resource "aws_s3_bucket" "terraform-test-s3-artifact" {
  bucket = "${var.env}-${var.project_name}-codepipeline-${var.region}-artifact"
  force_destroy = true
  acl    = "private"
}

#--------------------------------------------------------------
# s3kmskey Settings
#--------------------------------------------------------------

data "aws_kms_alias" "terraform-test-kms-alias" {
  name = "alias/aws/s3"
}

#--------------------------------------------------------------
# CodeBuild Role Policy
#--------------------------------------------------------------
data "template_file" "terraform-test-codebuild-assume" {
  template = "${file("../../modules/cicd/policies/codebuild_assume_policy.json.tpl")}"
}
resource "aws_iam_role" "terraform-test-codebuild-role" {
  name               = "codebuild-role"
  assume_role_policy = "${data.template_file.terraform-test-codebuild-assume.rendered}"
}

data "template_file" "terraform-test-codebuild-policy" {
  template = "${file("../../modules/cicd/policies/codebuild_policy.json.tpl")}"

  vars = {
    account_id            = "${var.account_id}"
    env                   = "${var.env}"
    region                = "${var.region}"
    project_name          = "${var.project_name}"
    artifact_bucket_name  = "${var.env}-${var.project_name}-codepipeline-${var.region}-artifact"
  }
}

resource "aws_iam_role_policy" "terraform-test-codebuild-policy" {
  name   = "codebuild-role-policy"
  role   = "${aws_iam_role.terraform-test-codebuild-role.id}"
  policy = "${data.template_file.terraform-test-codebuild-policy.rendered}"
}

#--------------------------------------------------------------
# CodeBuild Settings
#--------------------------------------------------------------
resource "aws_codebuild_project" "terraform-test-codebuild" {
  name          = "${var.env}-${var.project_name}-build-project"
  description   = "create for codepipeline stage"
  build_timeout = "60"
  service_role  = "${aws_iam_role.terraform-test-codebuild-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    buildspec       = "buildspec/buildspec-${var.env}.yml"
    type            = "CODEPIPELINE"
  }
}

#--------------------------------------------------------------
# CodePipeline Role
#--------------------------------------------------------------
data "template_file" "terraform-test-codepipeline-assume" {
  template = "${file("../../modules/cicd/policies/codepipeline_assume_policy.json.tpl")}"
}

resource "aws_iam_role" "terraform-test-codepipeline-role" {
  name               = "${var.env}-${var.project_name}-codepipeline-role"
  assume_role_policy = "${data.template_file.terraform-test-codepipeline-assume.rendered}"
}

data "template_file" "terraform-test-codepipeline-policy" {
  template = "${file("../../modules/cicd/policies/codepipeline_policy.json.tpl")}"
}

resource "aws_iam_role_policy" "terraform-test-codepipeline-policy" {
  name   = "codepipeline-role-policy"
  role   = "${aws_iam_role.terraform-test-codepipeline-role.id}"
  policy = "${data.template_file.terraform-test-codepipeline-policy.rendered}"
}

data "template_file" "terraform-test-codepipeline-s3-policy" {
  template = "${file("../../modules/cicd/policies/codepipeline_s3_policy.json.tpl")}"
  vars = {
    artifact_bucket_name = "${var.env}-${var.project_name}-codepipeline-${var.region}-artifact"
  }
}

resource "aws_s3_bucket_policy" "terraform-test-codepipeline-s3-policy" {
  bucket = "${aws_s3_bucket.terraform-test-s3-artifact.id}"
  policy = "${data.template_file.terraform-test-codepipeline-s3-policy.rendered}"
}

#--------------------------------------------------------------
# CodePipeline Settings
#--------------------------------------------------------------
resource "aws_codepipeline" "terraform-test-codepipeline" {
  name     = "${var.env}-${var.project_name}-codepipeline-main"
  role_arn = "${aws_iam_role.terraform-test-codepipeline-role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.terraform-test-s3-artifact.bucket}"
    type     = "S3"

    encryption_key {
      id   = "${data.aws_kms_alias.terraform-test-kms-alias.arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner      = "${var.github_account_name}" // GitHub Account
        OAuthToken = "${var.github_token}"        // GitHub Token
        Repo       = "${var.github_repository}"   // GitHub Repository Name
        Branch     = "${var.github_branch}"       // GitHub Push Branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration = {
        ProjectName = "${var.env}-${var.project_name}-build-project" //CodeBuild Name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build"]
      version         = "1"

      configuration = {
        ClusterName = "${var.env}-${var.project_name}-ecs-cluster"      //AWS ECS Cluster Name
        ServiceName = "${var.env}-${var.project_name}-springboot"      //AWS ECS Service Name
        FileName    = "${var.imagedefinitions_path}" //GitHub imagedefinitions.json Path
      }
    }
  }
}