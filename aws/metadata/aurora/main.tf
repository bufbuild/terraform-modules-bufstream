data "aws_vpc" "buf" {
  id = var.vpc_id
}

resource "random_string" "aurora_password" {
  length  = 20
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret" "aurora_pass_secret" {
  name = "${var.aurora_identifier}-cluster-pass"
}

resource "aws_secretsmanager_secret_version" "aurora_pass_sv" {
  secret_id     = aws_secretsmanager_secret.aurora_pass_secret.id
  secret_string = jsonencode({ "password" = "${random_string.aurora_password.result}" }) # matches 'manage_master_password' format
}

resource "aws_security_group" "aurora" {
  name   = "${var.aurora_identifier}-aurora-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.aurora_port
    to_port     = var.aurora_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.buf.cidr_block]
  }

}

resource "aws_db_subnet_group" "aurora" {
  name       = "${var.aurora_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.aurora_identifier}-subnet-group"
  }
}

data "aws_secretsmanager_secret_version" "db_pass_secret" {
  secret_id = aws_secretsmanager_secret.aurora_pass_secret.id
  depends_on = [
    aws_secretsmanager_secret.aurora_pass_secret,
    aws_secretsmanager_secret_version.aurora_pass_sv
  ]
}

resource "aws_rds_cluster" "bufpg" {
  cluster_identifier     = "${var.aurora_identifier}-bufstream-aurora"
  engine                 = "aurora-postgresql"
  engine_version         = var.postgres_version
  availability_zones     = [var.availability_zone]
  master_username        = var.postgres_username
  master_password        = jsondecode(data.aws_secretsmanager_secret_version.db_pass_secret.secret_string)["password"]
  port                   = var.aurora_port
  database_name          = var.postgres_db_name
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]
  skip_final_snapshot    = true

  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
}

resource "aws_rds_cluster_instance" "bufstream_aurora_instances" {
  count                = var.cluster_instance_count
  availability_zone    = var.availability_zone
  identifier           = "${var.aurora_identifier}-bufstream-aurora-${count.index}"
  cluster_identifier   = aws_rds_cluster.bufpg.id
  instance_class       = var.aurora_instance_class
  engine               = aws_rds_cluster.bufpg.engine
  engine_version       = aws_rds_cluster.bufpg.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.name
}


