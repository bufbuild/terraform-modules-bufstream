output "pg_dsn" {
  description = "Full DSN of the Postgres instance"

  value = "postgresql://${aws_db_instance.bufpg.username}:${aws_db_instance.bufpg.password}@${aws_db_instance.bufpg.endpoint}/${aws_db_instance.bufpg.db_name}?sslmode=require"

  sensitive = true
}
