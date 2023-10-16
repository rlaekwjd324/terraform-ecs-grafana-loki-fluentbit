resource "aws_db_parameter_group" "dory-terraform-test-paramgroup" {
  description = "Database Parameter Group"
  family      = "mysql8.0"
  name        = "${var.env}-${var.project_name}-paramgroup"
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
}

resource "aws_db_instance" "dory-terraform-test-rds" {
  allocated_storage                     = 5
  availability_zone                     = "ap-northeast-2a"
  backup_retention_period               = 1
  backup_window                         = "19:20-19:50"
  ca_cert_identifier                    = "rds-ca-2019"
  copy_tags_to_snapshot                 = false
  customer_owned_ip_enabled             = false
  db_name                               = "test"
  db_subnet_group_name                  = aws_db_subnet_group.dory-terraform-test-rds-subnet-group.id
  deletion_protection                   = false
  engine                                = "mysql"
  engine_version                        = "8.0.28"
  iam_database_authentication_enabled   = false
  identifier                            = "${var.env}-${var.project_name}-rds"
  instance_class                        = "db.t3.micro"
  license_model                         = "general-public-license"
  maintenance_window                    = "sun:16:11-sun:16:41"
  multi_az                              = false
  option_group_name                     = "default:mysql-8-0"
  parameter_group_name                  = "${var.env}-${var.project_name}-paramgroup"
  performance_insights_retention_period = 0
  publicly_accessible                   = true
  skip_final_snapshot                   = true
  storage_encrypted                     = false
  storage_type                          = "gp2"
  username                              = "root"
  password                              = "<DB_PASSWORD>"
  vpc_security_group_ids                = [aws_security_group.dory-terraform-test-rds-security-group.id]
}