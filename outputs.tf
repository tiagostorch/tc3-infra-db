output "db_endpoint" {
  value = aws_db_instance.principal.address
}

output "db_port" {
  value = aws_db_instance.principal.port
}

output "db_name" {
  value = var.db_name
}

# tc3-auth-lambda usa este id para autorizar a própria entrada no Postgres.
output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "ssm_database_url_name" {
  description = "Parâmetro lido pela aplicação e pela Lambda."
  value       = aws_ssm_parameter.database_url.name
}

output "ssm_prefix" {
  value = local.ssm_prefix
}
