output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}

output "vpc_id" {
  value = local.vpc_id
}
