output "pg_dsn" {
  description = "Partial DSN of the Postgres instance with env placeholder for password"

  value = "postgresql://${aws_rds_cluster.bufpg.master_username}:$PG_PASSWORD@${aws_rds_cluster.bufpg.endpoint}/${aws_rds_cluster.bufpg.database_name}?sslmode=require"

  sensitive = true
}

output "pg_pw_secret_arn" {
  description = "The ARN of the secret holding the PG password"
  value       = aws_secretsmanager_secret.aurora_pass_secret.arn
}
