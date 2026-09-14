resource "aws_db_subnet_group" "principal" {
  name       = "${local.identificador}-db"
  subnet_ids = local.private_subnet_ids
}

resource "aws_security_group" "db" {
  name        = "${local.identificador}-db"
  description = "Postgres acessivel apenas de dentro da VPC"
  vpc_id      = local.vpc_id
}

# Só os pods da aplicação entram por aqui. A Lambda de autenticação adiciona a
# própria regra a partir de tc3-auth-lambda, referenciando este mesmo grupo.
resource "aws_vpc_security_group_ingress_rule" "dos_nos_eks" {
  security_group_id            = aws_security_group.db.id
  description                  = "Postgres a partir dos nos do EKS"
  referenced_security_group_id = local.node_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "random_password" "db" {
  length = 32
  # Caracteres de pontuação quebram o parsing da connection string do Prisma.
  special = false
}

resource "aws_db_instance" "principal" {
  identifier = local.identificador

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.principal.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = true
  deletion_protection     = false

  # O log do Postgres não é mais exportado para o CloudWatch Logs: era o único
  # item cobrado por GB neste recurso e a telemetria hoje sai pelo nri-postgresql,
  # que consulta o banco direto de dentro do cluster.
  #
  # O Performance Insights fica ligado porque é gratuito nos 7 dias de retenção
  # e resolve a pergunta que métrica agregada não responde — qual query está
  # segurando a conexão. Ele não passa pelo CloudWatch: é console do RDS.
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = 7

  apply_immediately = true
}
