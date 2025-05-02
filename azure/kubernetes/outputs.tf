output "bufstream_identity" {
  description = "Bufstream Identity ID"
  value       = local.bufstream_id_ref
}

output "cluster_name" {
  description = "Container Cluster Endpoint"
  value       = local.cluster_ref.name
}

output "cert" {
  description = "Container Cluster Certificate"
  value       = local.cluster_ref.kube_config[0].cluster_ca_certificate
}

output "endpoint" {
  description = "Container Cluster Endpoint"
  value       = local.cluster_ref.kube_config[0].host
}

output "client_cert" {
  description = "Container Cluster Client Certificate"
  value       = local.cluster_ref.kube_config[0].client_certificate
}

output "client_key" {
  description = "Container Cluster Client Key"
  value       = local.cluster_ref.kube_config[0].client_key
}

output "admin_user" {
  description = "Container Cluster Admin User"
  value       = local.cluster_ref.kube_config[0].username
}

output "admin_password" {
  description = "Container Cluster Admin Password"
  value       = local.cluster_ref.kube_config[0].password
}
