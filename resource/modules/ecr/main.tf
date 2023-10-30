resource "aws_ecr_repository" "terraform-test" {
  name                 = "${var.env}-${var.project_name}-api"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}