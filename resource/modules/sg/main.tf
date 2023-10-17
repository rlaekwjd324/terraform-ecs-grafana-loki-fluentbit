
# SG
resource "aws_security_group" "terraform-test-private-ec2" {
  description = "Allow access from HTTP and SSH traffic"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    from_port       = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform-test-public-ec2.id]
    to_port         = 22
  }
  ingress {
    from_port   = 0
    protocol    = "tcp"
    security_groups = [aws_security_group.terraform-test-alb.id]
    to_port     = 65535
  }
  name = "${var.env}-${var.project_name}-private-ec2"
  tags = {
    Name = "${var.env}-${var.project_name}-private-ec2"
  }
  vpc_id = var.vpc_id
}

resource "aws_security_group" "terraform-test-public-ec2" {
  description = "Allow access from SSH traffic for Bastion Host"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["${var.vpc_ssh_ingress_cidr_block}"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  name = "${var.env}-${var.project_name}-public-ec2"
  tags = {
    Name = "${var.env}-${var.project_name}-public-ec2"
  }
  vpc_id = var.vpc_id
}

resource "aws_security_group" "terraform-test-alb" {
  description = "Allow access from HTTP traffic"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    from_port   = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    to_port     = 65535
  }
  name = "${var.env}-${var.project_name}-alb"
  tags = {
    Name = "${var.env}-${var.project_name}-alb"
  }
  vpc_id = var.vpc_id
}

resource "aws_security_group" "terraform-test-rds-security-group" {
  description = "Allow access from 3306 traffic"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks     = ["${var.vpc_ssh_ingress_cidr_block}"]
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform-test-private-ec2.id]
    to_port         = 3306
  }
  name = "${var.env}-${var.project_name}-rds-security-group"
  tags = {
    Name = "${var.env}-${var.project_name}-rds-sg"
  }
  vpc_id = var.vpc_id
}