data "aws_vpc" "buf" {
  id = var.vpc_id
}

resource "aws_security_group" "rds" {
  name   = "${var.rds_identifier}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.rds_port
    to_port     = var.rds_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.buf.cidr_block]
  }

}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.rds_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.rds_identifier}-subnet-group"
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

