
# SG
resource "aws_security_group" "dory-terraform-test-private-ec2" {
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
    security_groups = [aws_security_group.dory-terraform-test-public-ec2.id]
    to_port         = 22
  }
  ingress {
    from_port   = 0
    protocol    = "tcp"
    security_groups = [aws_security_group.dory-terraform-test-alb.id]
    to_port     = 65535
  }
  name = "dory-terraform-test-private-ec2"
  tags = {
    Name = "dory-terraform-test-private-ec2"
  }
  vpc_id = aws_vpc.dory-terraform-test-vpc.id

  depends_on = [aws_vpc.dory-terraform-test-vpc]
}

resource "aws_security_group" "dory-terraform-test-public-ec2" {
  description = "Allow access from SSH traffic for Bastion Host"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks = ["10.5.0.0/32"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  name = "dory-terraform-test-public-ec2"
  tags = {
    Name = "dory-terraform-test-public-ec2"
  }
  vpc_id = aws_vpc.dory-terraform-test-vpc.id

  depends_on = [aws_vpc.dory-terraform-test-vpc]
}

resource "aws_security_group" "dory-terraform-test-alb" {
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
  name = "dory-terraform-test-alb"
  tags = {
    Name = "dory-terraform-test-alb"
  }
  vpc_id = aws_vpc.dory-terraform-test-vpc.id

  depends_on = [aws_vpc.dory-terraform-test-vpc]
}

resource "aws_security_group" "dory-terraform-test-rds-security-group" {
  description = "Allow access from 3306 traffic"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  ingress {
    cidr_blocks     = ["10.5.0.0/32"]
    from_port       = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dory-terraform-test-private-ec2.id]
    to_port         = 3306
  }
  name = "dory-terraform-test-rds-security-group"
  tags = {
    Name = "dory-terraform-test-rds-sg"
  }
  vpc_id = aws_vpc.dory-terraform-test-vpc.id
}