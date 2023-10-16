resource "aws_instance" "dory-terraform-test-public-ec2-bastion-host" {
  ami                         = "ami-0b23bb3616e3892a6"
  associate_public_ip_address = true
  credit_specification {
    cpu_credits = "unlimited"
  }
  disable_api_termination = false
  ebs_optimized           = false
  enclave_options {
    enabled = false
  }
  hibernation                          = false
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  key_name                             = "${var.env}-${var.project_name}-bastion-host-key"
  metadata_options {
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  monitoring = false
  root_block_device {
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  subnet_id = aws_subnet.dory-terraform-test-public-subnet-1.id
  tags = {
    Name = "${var.env}-${var.project_name}-public-ec2-bastion-host"
  }
  tenancy                = "default"
  vpc_security_group_ids = [aws_security_group.dory-terraform-test-public-ec2.id]
}

resource "aws_key_pair" "dory-terraform-test-bastion-host-key" {
  key_name   = "${var.env}-${var.project_name}-bastion-host-key"
  public_key = tls_private_key.dory-terraform-test_key.public_key_openssh
  tags = {
    Name = "${var.env}-${var.project_name}-bastion-host-key"
  }
}

resource "aws_key_pair" "dory-terraform-test-private-ec2-key" {
  key_name   = "${var.env}-${var.project_name}-private-ec2-key"
  public_key = tls_private_key.dory-terraform-test_key.public_key_openssh
  tags = {
    Name = "${var.env}-${var.project_name}-private-ec2-key"
  }
}

resource "tls_private_key" "dory-terraform-test_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "dory-terraform-test-private-ec2-key" {
  filename        = "./.ssh/d${var.env}-${var.project_name}-private-ec2-key.pem"
  content         = tls_private_key.dory-terraform-test_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "dory-terraform-test-bastion-host-key" {
  filename        = "./.ssh/${var.env}-${var.project_name}-bastion-host-key.pem"
  content         = tls_private_key.dory-terraform-test_key.private_key_pem
  file_permission = "0600"
}