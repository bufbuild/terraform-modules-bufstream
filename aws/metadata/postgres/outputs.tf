output "pg_dsn" {
  description = "Partial DSN of the Postgres instance with env placeholder for password"

  value = "postgresql://${aws_db_instance.bufpg.username}:$PG_PASSWORD@${aws_db_instance.bufpg.endpoint}/${aws_db_instance.bufpg.db_name}?sslmode=require"

  sensitive = true
}

output "pg_pw_secret_arn" {
  description = "The ARN of the secret holding the PG password"
  value       = aws_db_instance.bufpg.master_user_secret[0].secret_arn
}
