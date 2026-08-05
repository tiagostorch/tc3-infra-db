# Ponto único de verdade das credenciais: a aplicação e a Lambda leem daqui, e
# nenhuma senha circula por secret do GitHub ou manifesto do Kubernetes.

locals {
  ssm_prefix = "/${var.project_name}/${var.environment}"

  # Formato esperado pelo @prisma/adapter-pg.
  database_url = format(
    "postgresql://%s:%s@%s:%s/%s?schema=public",
    var.db_username,
    random_password.db.result,
    aws_db_instance.principal.address,
    aws_db_instance.principal.port,
    var.db_name,
  )
}

resource "aws_ssm_parameter" "database_url" {
  name        = "${local.ssm_prefix}/DATABASE_URL"
  description = "Connection string do Prisma"
  type        = "SecureString"
  value       = local.database_url
}

resource "aws_ssm_parameter" "db_host" {
  name  = "${local.ssm_prefix}/DB_HOST"
  type  = "String"
  value = aws_db_instance.principal.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "${local.ssm_prefix}/DB_PORT"
  type  = "String"
  value = tostring(aws_db_instance.principal.port)
}

resource "aws_ssm_parameter" "db_name" {
  name  = "${local.ssm_prefix}/DB_NAME"
  type  = "String"
  value = var.db_name
}

resource "aws_ssm_parameter" "db_user" {
  name  = "${local.ssm_prefix}/DB_USER"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_prefix}/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.db.result
}
