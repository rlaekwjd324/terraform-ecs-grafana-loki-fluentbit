#--------------------------------------------------------------
# S3 bucket Setting
#--------------------------------------------------------------
resource "aws_s3_bucket" "terraform-test-s3-artifact" {
  bucket = "${var.artifact_bucket_name}"
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
data "template_file" "codebuild_assume" {
  template = "${file("./policies/codebuild_assume_policy.json.tpl")}"
}
resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = "${data.template_file.codebuild_assume.rendered}"
}

data "template_file" "codebuild_policy" {
  template = "${file("./policies/codebuild_policy.json.tpl")}"

  vars = {
    account_id     = "${var.account_id}"
    codebuild_name = "${var.codebuild_name}"
    bucket_name    = "${var.artifact_bucket_name}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-role-policy"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

#--------------------------------------------------------------
# CodeBuild Settings
#--------------------------------------------------------------
resource "aws_codebuild_project" "main_build" {
  name          = "${var.codebuild_name}"
  description   = "create for codepipeline stage"
  build_timeout = "60"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

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
    buildspec       = "buildspec/buildspec-dev.yml"
    type            = "CODEPIPELINE"
  }
}

#--------------------------------------------------------------
# CodePipeline Role
#--------------------------------------------------------------
data "template_file" "codepipeline_assume" {
  template = "${file("./policies/codepipeline_assume_policy.json.tpl")}"
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-role"
  assume_role_policy = "${data.template_file.codepipeline_assume.rendered}"
}

data "template_file" "codepipeline_policy" {
  template = "${file("./policies/codepipeline_policy.json.tpl")}"
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline-role-policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

data "template_file" "codepipeline_s3_policy" {
  template = "${file("./policies/codepipeline_s3_policy.json.tpl")}"
  vars = {
    bucket_name = "${var.artifact_bucket_name}"
  }
}

resource "aws_s3_bucket_policy" "codepipeline_s3_policy" {
  bucket = "${aws_s3_bucket.terraform-test-s3-artifact.id}"
  policy = "${data.template_file.codepipeline_s3_policy.rendered}"
}

#--------------------------------------------------------------
# CodePipeline Settings
#--------------------------------------------------------------
resource "aws_codepipeline" "main" {
  name     = "codepipeline-main"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

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
        ProjectName = "${var.codebuild_name}" //CodeBuild Name
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
        ClusterName = "${var.ecs_cluster_name}"      //AWS ECS Cluster Name
        ServiceName = "${var.ecs_service_name}"      //AWS ECS Service Name
        FileName    = "${var.imagedefinitions_path}" //GitHub imagedefinitions.json Path
      }
    }
  }
}