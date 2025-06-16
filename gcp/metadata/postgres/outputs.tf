output "cloudsql_instance_name" {
  value = google_sql_database_instance.bufpg.name
}

output "database_name" {
  value = google_sql_database.bufdb.name
}

output "cloudsql_service_account" {
  value = google_sql_database_instance.bufpg.service_account_email_address
}

