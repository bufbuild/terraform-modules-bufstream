resource "random_string" "rds_identifier" {
  count   = var.rds_identifier == null ? 1 : 0
  length  = 16
  special = false
  numeric = false
}

resource "random_password" "postgres_password" {
  count   = var.postgres_password == null ? 1 : 0
  length  = 32
  special = false
}

locals {
  identifier        = var.rds_identifier != null ? var.rds_identifier : random_string.rds_identifier[0].result
  postgres_password = var.postgres_password != null ? var.postgres_password : random_password.postgres_password[0].result
}

data "aws_vpc" "buf" {
  id = var.vpc_id
}

resource "aws_security_group" "rds" {
  name   = "${local.identifier}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.buf.cidr_block]
  }

}

resource "aws_db_subnet_group" "rds" {
  name       = "${local.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "bufpg" {
  identifier          = local.identifier
  engine              = "postgres"
  engine_version      = var.postgres_version
  username            = var.postgres_username
  password            = local.postgres_password
  allocated_storage   = var.rds_allocated_storage
  port                = var.rds_port
  instance_class      = var.rds_instance_class
  db_name             = var.postgres_db_name
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}
