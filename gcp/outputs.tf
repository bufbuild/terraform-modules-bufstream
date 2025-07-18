output "bufstream_values" {
  description = "Values file for bufstream."
  value       = local.bufstream_values
}

output "kubeconfig" {
  description = "Kubeconfig file to access the cluster."
  value       = local.kubeconfig
}
