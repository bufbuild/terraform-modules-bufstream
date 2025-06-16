output "vpc_ref" {
  description = "Reference to VPC."
  value       = local.vpc_ref
}

output "vpc_id" {
  value = local.vpc_id
}

output "subnet_ref" {
  description = "Reference to Subnet in VPC."
  value       = local.subnet_ref
}

output "private_service_network" {
  description = "Private service networking connection"
  value       = google_service_networking_connection.private_service_networking
}
