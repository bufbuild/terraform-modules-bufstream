provider "aws" {
  region = var.region
}

resource "random_string" "deployment_id" {
  length  = 10
  special = false
  numeric = false
  upper   = false
}

locals {
  deploy_id = random_string.deployment_id.result
  cluster_name = var.eks_cluster_name == null ? "bufstream-${local.deploy_id}" : var.eks_cluster_name
  vpc_name = var.vpc_name == null ? "bufstream-vpc-${local.deploy_id}" : var.vpc_name
}

module "network" {
  source             = "./network"
  create_vpc         = var.create_vpc
  vpc_name           = local.vpc_name
  vpc_id             = var.vpc_id
  vpc_cidr           = var.vpc_cidr
  create_subnets     = var.create_subnets
  create_igw         = var.create_igw
  create_s3_endpoint = var.create_s3_endpoint
  s3_vpc_endpoint    = var.s3_vpc_endpoint
}

module "kubernetes" {
  source                         = "./kubernetes"
  cluster_name                   = local.cluster_name
  cluster_version                = var.eks_cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  subnet_ids                     = length(var.subnet_ids) == 0 ? module.network.private_subnet_ids : var.subnet_ids
  use_pod_identity               = var.use_pod_identity
  bufstream_namespace            = var.bufstream_k8s_namespace
  bufstream_service_account      = var.bufstream_service_account
  deployment_id                  = random_string.deployment_id.result
}

module "storage" {
  source         = "./storage"
  bucket_name    = var.bucket_name
  bufstream_role = module.kubernetes.bufstream_role_name
}

locals {
  create_pg = var.bufstream_metadata == "postgres"
}

module "postgres" {
  source = "./metadata/postgres"
  count  = local.create_pg ? 1 : 0

  vpc_id                = var.vpc_id == "" ? module.network.vpc_id : var.vpc_id
  subnet_ids            = length(var.subnet_ids) == 0 ? module.network.private_subnet_ids : var.subnet_ids
  rds_identifier        = var.rds_identifier
  postgres_username     = var.postgres_username
  rds_port              = var.rds_port
  rds_instance_class    = var.rds_instance_class
  postgres_version      = var.postgres_version
  rds_allocated_storage = var.rds_allocated_storage
  postgres_db_name      = var.postgres_db_name
}

# We create this here so we can have the hostname ready for bufstream.
# The ingress controller will assume control after the helm install.
resource "aws_security_group" "bufstream-nlb" {
  count  = var.create_nlb ? 1 : 0
  name   = "bufstream-${random_string.deployment_id.result}"
  vpc_id = module.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "bufstream" {
  count              = var.create_nlb ? 1 : 0
  name               = "bufstream-app-${random_string.deployment_id.result}"
  internal           = var.internal_only_nlb
  load_balancer_type = "network"
  subnets            = var.internal_only_nlb ? module.network.private_subnet_ids : module.network.public_subnet_ids
  security_groups    = [aws_security_group.bufstream-nlb[0].id]

  tags = {
    "eks:eks-cluster-name"               = module.kubernetes.cluster_name
    "service.eks.amazonaws.com/resource" = "LoadBalancer"
    "service.eks.amazonaws.com/stack"    = "${var.bufstream_k8s_namespace}/bufstream"
  }

  # Ignore changing SG since ALB controller will add them
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}

locals {
  bufstream_values = templatefile("${path.module}/bufstream.yaml.tpl", {
    region      = var.region
    bucket_name = module.storage.bucket_ref
    hostname    = var.create_nlb ? aws_lb.bufstream[0].dns_name : ""
    role_arn    = var.use_pod_identity ? "" : module.kubernetes.bufstream_role_arn
    metadata    = var.bufstream_metadata
    lb_scheme   = var.internal_only_nlb ? "internal" : "internet-facing"
  })

  kubeconfig = templatefile("${path.module}/kubeconfig.yaml.tpl", {
    region              = var.region
    cluster_name        = local.cluster_name
    cluster_arn         = module.kubernetes.cluster_arn
    cluster_endpoint    = module.kubernetes.cluster_endpoint
    cluster_certificate = module.kubernetes.cluster_certificate
    aws_profile         = var.profile
  })

  pg_secret = local.create_pg ? templatefile("${path.module}/pg-setup.sh.tpl", {
    region      = var.region
    secret_arn  = module.postgres[0].pg_pw_secret_arn
    dsn         = module.postgres[0].pg_dsn
    aws_profile = var.profile
  }) : null
}

resource "local_file" "pg_secret_script" {
  count    = var.generate_config_files_path != null && local.create_pg ? 1 : 0
  content  = local.pg_secret
  filename = "${var.generate_config_files_path}/aws-pg-setup.sh"
}

resource "local_file" "bufstream_values" {
  count    = var.generate_config_files_path != null ? 1 : 0
  content  = local.bufstream_values
  filename = "${var.generate_config_files_path}/bufstream.yaml"

  file_permission = "0600"
}

resource "local_file" "kubeconfig" {
  count    = var.generate_config_files_path != null ? 1 : 0
  content  = local.kubeconfig
  filename = "${var.generate_config_files_path}/kubeconfig.yaml"

  file_permission = "0600"
}
