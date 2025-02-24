output "bufstream_role_name" {
  value = aws_iam_role.bufstream_role.name
}

output "bufstream_role_arn" {
  value = aws_iam_role.bufstream_role.arn
}

output "cluster_certificate" {
  value = aws_eks_cluster.bufstream.certificate_authority[0].data
}

output "cluster_endpoint" {
  value = aws_eks_cluster.bufstream.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.bufstream.arn
}

output "cluster_name" {
  value = aws_eks_cluster.bufstream.name
}
