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

  # Alimenta os dashboards de banco na ferramenta de observabilidade.
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["postgresql"]

  apply_immediately = true
}
