data "aws_vpc" "buf" {
  id = var.vpc_id
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

resource "aws_rds_cluster" "bufpg" {
  cluster_identifier          = "${var.aurora_identifier}-bufstream-aurora"
  engine                      = "aurora-postgresql"
  engine_version              = var.postgres_version
  availability_zones          = [var.availability_zone]
  master_username             = var.postgres_username
  port                        = var.aurora_port
  database_name               = var.postgres_db_name
  db_subnet_group_name        = aws_db_subnet_group.aurora.name
  vpc_security_group_ids      = [aws_security_group.aurora.id]
  manage_master_user_password = true
  skip_final_snapshot         = true
}

resource "aws_rds_cluster_instance" "bufstream_aurora_instances" {
  count                = 2
  availability_zone    = var.availability_zone
  identifier           = "${var.aurora_identifier}-bufstream-aurora-${count.index}"
  cluster_identifier   = aws_rds_cluster.bufpg.id
  instance_class       = var.aurora_instance_class
  engine               = aws_rds_cluster.bufpg.engine
  engine_version       = aws_rds_cluster.bufpg.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurora.name
}
