output "vpc_ref" {
  description = "Reference to VPC."
  value       = local.vpc_ref
}

output "subnet_ref" {
  description = "Reference to Subnet in VPC."
  value       = local.subnet_ref
}
