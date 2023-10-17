resource "aws_instance" "terraform-test-public-ec2-bastion-host" {
  ami                         = "${var.bastion_host_instance_ami}"
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
  instance_type                        = "${var.bastion_host_instance_type}"
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
  subnet_id = var.public_subnet_1_id
  tags = {
    Name = "${var.env}-${var.project_name}-public-ec2-bastion-host"
  }
  tenancy                = "default"
  vpc_security_group_ids = [var.public_ec2_sg_id]
}

resource "aws_key_pair" "terraform-test-bastion-host-key" {
  key_name   = "${var.env}-${var.project_name}-bastion-host-key"
  public_key = tls_private_key.terraform-test_key.public_key_openssh
  tags = {
    Name = "${var.env}-${var.project_name}-bastion-host-key"
  }
}

resource "aws_key_pair" "terraform-test-private-ec2-key" {
  key_name   = "${var.env}-${var.project_name}-private-ec2-key"
  public_key = tls_private_key.terraform-test_key.public_key_openssh
  tags = {
    Name = "${var.env}-${var.project_name}-private-ec2-key"
  }
}

resource "tls_private_key" "terraform-test_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "terraform-test-private-ec2-key" {
  filename        = "./.ssh/${var.env}-${var.project_name}-private-ec2-key.pem"
  content         = tls_private_key.terraform-test_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "terraform-test-bastion-host-key" {
  filename        = "./.ssh/${var.env}-${var.project_name}-bastion-host-key.pem"
  content         = tls_private_key.terraform-test_key.private_key_pem
  file_permission = "0600"
}