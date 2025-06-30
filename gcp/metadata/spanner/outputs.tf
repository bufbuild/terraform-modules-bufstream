output "spanner_instance_id" {
  description = "The ID of the Spanner instance"
  value       = google_spanner_instance.bufstream.id
}

output "spanner_instance_name" {
  description = "The name of the Spanner instance"
  value       = google_spanner_instance.bufstream.name
}

output "spanner_config" {
  description = "The configuration of the Spanner instance"
  value       = google_spanner_instance.bufstream.config
}
