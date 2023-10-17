resource "aws_vpc" "terraform-test-vpc" {
  cidr_block                     = "${var.vpc_cidr_bolock}"
  enable_dns_hostnames           = true
  tags                           = {
    Name = "${var.env}-${var.project_name}-vpc"
  }
}

resource "aws_subnet" "terraform-test-public-subnet-1" {
  cidr_block                          = "${var.public_subnet_1_cidr_block}"
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = "${var.region}a"
  tags                                = {
    Name = "${var.env}-${var.project_name}-public-subnet-1"
  }
  map_public_ip_on_launch             = true
  vpc_id                              = aws_vpc.terraform-test-vpc.id
}

resource "aws_subnet" "terraform-test-public-subnet-5" {
  cidr_block                          = "${var.public_subnet_5_cidr_block}"
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = "${var.region}a"
  tags                                = {
    Name = "${var.env}-${var.project_name}-public-subnet-5"
  }
  vpc_id                              = aws_vpc.terraform-test-vpc.id
}

resource "aws_subnet" "terraform-test-private-subnet-3" {
  cidr_block                          = "${var.private_subnet_3_cidr_block}"
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = "${var.region}a"
  tags                                = {
    Name = "${var.env}-${var.project_name}-private-subnet-3"
  }
  vpc_id                              = aws_vpc.terraform-test-vpc.id
}

resource "aws_subnet" "terraform-test-public-subnet-2" {
  cidr_block                          = "${var.public_subnet_2_cidr_block}"
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = "${var.region}c"
  tags                                = {
    Name = "${var.env}-${var.project_name}-public-subnet-2"
  }
  map_public_ip_on_launch             = true
  vpc_id                              = aws_vpc.terraform-test-vpc.id
}

resource "aws_subnet" "terraform-test-public-subnet-6" {
  cidr_block                          = "${var.public_subnet_6_cidr_block}"
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = "${var.region}c"
  tags                                = {
    Name = "${var.env}-${var.project_name}-public-subnet-6"
  }
  vpc_id                              = aws_vpc.terraform-test-vpc.id
}

resource "aws_db_subnet_group" "terraform-test-rds-subnet-group" {
  description = "development rds subnet group"
  name        = "${var.env}-${var.project_name}-rds-subnet-group"
  subnet_ids  = [aws_subnet.terraform-test-public-subnet-5.id, aws_subnet.terraform-test-public-subnet-6.id]
}

resource "aws_internet_gateway" "terraform-test-igw" {
  tags = {
    Name = "${var.env}-${var.project_name}-igw"
  }
  vpc_id = aws_vpc.terraform-test-vpc.id
}

resource "aws_route_table" "terraform-test-public-rt" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-test-igw.id
  }
  tags   = {
    Name = "${var.env}-${var.project_name}-public-rt"
  }
  vpc_id = aws_vpc.terraform-test-vpc.id
}

resource "aws_eip" "terraform-test-nat-eip" {
    domain = "vpc"
    tags = {
        Name = "${var.env}-${var.project_name}-nat-eip"    
    }
}

resource "aws_nat_gateway" "terraform-test-nat" {
  allocation_id = aws_eip.terraform-test-nat-eip.id
  subnet_id     = aws_subnet.terraform-test-public-subnet-1.id
  tags          = {
    Name = "${var.env}-${var.project_name}-nat"
  }
}

resource "aws_route_table_association" "route_table_association_public_1" {
  route_table_id = aws_route_table.terraform-test-public-rt.id
  subnet_id      = aws_subnet.terraform-test-public-subnet-1.id
}

resource "aws_route_table_association" "route_table_association_public_2" {
  route_table_id = aws_route_table.terraform-test-public-rt.id
  subnet_id      = aws_subnet.terraform-test-public-subnet-2.id
}

resource "aws_route_table_association" "route_table_association_public_3" {
  route_table_id = aws_route_table.terraform-test-public-rt.id
  subnet_id      = aws_subnet.terraform-test-public-subnet-5.id
}

resource "aws_route_table_association" "route_table_association_public_4" {
  route_table_id = aws_route_table.terraform-test-public-rt.id
  subnet_id      = aws_subnet.terraform-test-public-subnet-6.id
}

resource "aws_route_table" "terraform-test-private-rt" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-test-nat.id
  }
  tags = {
    Name = "${var.env}-${var.project_name}-private-rt"
  }
  vpc_id = aws_vpc.terraform-test-vpc.id
}

resource "aws_route_table_association" "route_table_association_private_1" {
  route_table_id = aws_route_table.terraform-test-private-rt.id
  subnet_id      = aws_subnet.terraform-test-private-subnet-3.id
}