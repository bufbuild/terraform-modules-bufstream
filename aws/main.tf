module "network" {
  source             = "./network"
  create_vpc         = var.create_vpc
  vpc_name           = var.vpc_name
  vpc_id             = var.vpc_id
  vpc_cidr           = var.vpc_cidr
  create_subnets     = var.create_subnets
  create_igw         = var.create_igw
  create_s3_endpoint = var.create_s3_endpoint
  s3_vpc_endpoint    = var.s3_vpc_endpoint
}

module "kubernetes" {
  source                         = "./kubernetes"
  cluster_name                   = var.eks_cluster_name
  cluster_version                = var.eks_cluster_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  subnet_ids                     = length(var.subnet_ids) == 0 ? module.network.private_subnet_ids : var.subnet_ids
  use_pod_identity               = var.use_pod_identity
  bufstream_namespace            = var.bufstream_k8s_namespace
  bufstream_service_account      = var.bufstream_service_account
}

module "storage" {
  source         = "./storage"
  bucket_name    = var.bucket_name
  bufstream_role = module.kubernetes.bufstream_role_name
}

# We create this here so we can have the hostname ready for bufstream.
# The ingress controller will assume control after the helm install.
resource "aws_security_group" "bufstream-nlb" {
  count  = var.create_nlb ? 1 : 0
  name   = "bufstream"
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
  name               = "bufstream-app"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.network.private_subnet_ids
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
  context = module.kubernetes.cluster_arn

  bufstream_values = templatefile("${path.module}/bufstream.yaml.tpl", {
    region      = var.region
    bucket_name = module.storage.bucket_ref
    hostname    = var.create_nlb ? aws_lb.bufstream[0].dns_name : ""
    role_arn    = var.use_pod_identity ? "" : module.kubernetes.bufstream_role_arn
  })

  kubeconfig = templatefile("${path.module}/kubeconfig.yaml.tpl", {
    region              = var.region
    cluster_name        = var.eks_cluster_name
    cluster_arn         = module.kubernetes.cluster_arn
    cluster_endpoint    = module.kubernetes.cluster_endpoint
    cluster_certificate = module.kubernetes.cluster_certificate
    aws_profile         = var.profile
  })
}

resource "local_file" "context" {
  count    = var.generate_config_files_path != null ? 1 : 0
  content  = local.context
  filename = "${var.generate_config_files_path}/context"

  file_permission = "0600"
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
