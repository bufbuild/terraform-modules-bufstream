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

variable "rds_identifier" {
  description = "Identifier of the RDS instance"
  type        = string
  default     = null
}

resource "random_string" "rds_identifier" {
  length  = 16
  special = false
  numeric = false
  upper   = false
}

locals {
  identifier = var.rds_identifier != null ? var.rds_identifier : random_string.rds_identifier.result
}

resource "aws_db_subnet_group" "rds" {
  name       = "${local.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${local.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "bufpg" {
  engine                      = "postgres"
  engine_version              = var.postgres_version
  username                    = var.postgres_username
  manage_master_user_password = true
  allocated_storage           = var.rds_allocated_storage
  port                        = var.rds_port
  instance_class              = var.rds_instance_class
  db_name                     = var.postgres_db_name
  skip_final_snapshot         = true

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}
