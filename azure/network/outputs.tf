output "cluster_subnet" {
  description = "Cluster subnet"
  value       = local.cluster_subnet_ref
}

output "pods_subnet" {
  description = "Pods subnet"
  value       = local.pods_subnet_ref
}
