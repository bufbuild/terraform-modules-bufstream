output "cluster_name" {
  description = "Cluster Name"
  value       = local.cluster_name
}

output "cluster_region" {
  description = "Cluster Region"
  value       = local.cluster_region
}

output "bufstream_service_account" {
  description = "Bufstream Service Account Email"
  value       = local.bufstream_sa_email
}

output "endpoint" {
  description = "Container Cluster Endpoint"
  value       = local.cluster_endpoint
}

output "cert" {
  description = "Container Cluster Certificate"
  value       = local.cluster_cert
}
