locals {
  oidc_url = var.use_pod_identity ? "unused" : aws_iam_openid_connect_provider.irsa[0].url
  oidc_arn = var.use_pod_identity ? "unused" : aws_iam_openid_connect_provider.irsa[0].arn
}

data "aws_caller_identity" "this" {}

resource "aws_eks_cluster" "bufstream" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = false

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = var.cluster_endpoint_public_access
    subnet_ids              = var.subnet_ids
  }

  access_config {
    bootstrap_cluster_creator_admin_permissions = true
    authentication_mode                         = "API_AND_CONFIG_MAP"
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
}

resource "aws_iam_role" "node" {
  name = "eks-auto-node-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-${var.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}

data "aws_iam_policy_document" "bufstream_pod_identity" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["pods.eks.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.this.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnEquals"
      values   = [aws_eks_cluster.bufstream.arn]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "bufstream_irsa" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [local.oidc_arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:${var.bufstream_namespace}:${var.bufstream_service_account}"]
      variable = "${local.oidc_url}:sub"
    }
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "${local.oidc_url}:aud"
    }
  }
}

data "tls_certificate" "irsa" {
  url = aws_eks_cluster.bufstream.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "irsa" {
  count           = var.use_pod_identity ? 0 : 1
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.irsa.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.bufstream.identity[0].oidc[0].issuer

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_iam_role" "bufstream_role" {
  name = "BufstreamRole-${var.deployment_id}"

  assume_role_policy = var.use_pod_identity ? data.aws_iam_policy_document.bufstream_pod_identity.json : data.aws_iam_policy_document.bufstream_irsa.json
}

resource "aws_eks_pod_identity_association" "bufstream" {
  count           = var.use_pod_identity ? 1 : 0
  cluster_name    = aws_eks_cluster.bufstream.name
  namespace       = var.bufstream_namespace
  service_account = var.bufstream_service_account
  role_arn        = aws_iam_role.bufstream_role.arn
}
