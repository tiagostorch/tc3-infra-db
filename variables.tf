variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "tc3-oficina"
}

variable "environment" {
  type    = string
  default = "homolog"
}

variable "state_bucket" {
  description = "Bucket do state remoto — o mesmo criado no bootstrap de tc3-infra-k8s."
  type        = string
}

variable "db_name" {
  type    = string
  default = "oficina_db"
}

variable "db_username" {
  type    = string
  default = "oficina_user"
}

variable "db_engine_version" {
  description = <<-EOT
    Apenas a major. O RDS escolhe a minor suportada no momento da criação — a
    17.4 que estava fixada aqui nem existe mais em us-east-1, onde hoje a
    família começa na 17.5. Fixar a minor quebra o apply quando ela sai de linha.
  EOT
  type        = string
  default     = "17"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_backup_retention_days" {
  type    = number
  default = 1
}

variable "performance_insights_enabled" {
  description = <<-EOT
    Performance Insights do RDS. Gratuito na retenção de 7 dias e independente
    do CloudWatch — é console do próprio RDS. Fica ligado por padrão porque
    responde a pergunta que a métrica agregada não responde: qual query está
    prendendo a conexão.
  EOT
  type        = bool
  default     = true
}

# ─── Monitoria do banco (New Relic) ─────────────────────────────────────────
# O agente roda no cluster e consulta o Postgres direto. Substitui o que antes
# vinha do namespace AWS/RDS pelo CloudWatch.

variable "newrelic_namespace" {
  description = "Namespace criado por tc3-infra-k8s onde os componentes do New Relic vivem."
  type        = string
  default     = "newrelic"
}

variable "db_monitor_user" {
  description = <<-EOT
    Usuário de leitura usado pelo nri-postgresql. Criado por um Job de bootstrap
    com `pg_monitor` — a role que o próprio Postgres oferece para ferramenta de
    monitoria: enxerga as visões `pg_stat_*` inteiras e não lê dado de negócio.
  EOT
  type        = string
  default     = "newrelic_monitor"
}

variable "newrelic_infra_bundle_tag" {
  description = <<-EOT
    Tag da imagem `newrelic/infrastructure-bundle`, que empacota o agente de
    infraestrutura com as integrações on-host — entre elas o nri-postgresql.

    Fica em `latest` por padrão para o ambiente subir sem consulta prévia ao
    registry. Antes de promover para produção, travar numa tag concreta
    (`docker image inspect` depois do primeiro apply devolve a que está rodando):
    imagem móvel é a origem clássica do "funcionava ontem".
  EOT
  type        = string
  default     = "latest"
}

variable "newrelic_tags" {
  description = <<-EOT
    Tags padrão do projeto, aplicadas como atributos em toda amostra do agente
    de banco (NRIA_CUSTOM_ATTRIBUTES). Os dashboards e alertas de banco em
    tc3-infra-k8s filtram por elas — os valores precisam ser os mesmos de
    `newrelic_tags` lá. Separadas de `environment`, que compõe nomes de recurso
    (RDS, SSM) e não pode mudar sem recriar o banco.
  EOT
  type        = map(string)
  default = {
    environment = "production"
    project     = "tech-challenge-fiap"
  }

  validation {
    condition     = alltrue([for chave in ["environment", "project"] : contains(keys(var.newrelic_tags), chave)])
    error_message = "newrelic_tags precisa conter as chaves 'environment' e 'project'."
  }
}

variable "newrelic_postgres_interval" {
  description = <<-EOT
    Intervalo de coleta do banco. 30s acompanha o `lowDataMode` do agente de
    Kubernetes; abaixo disso o ganho é marginal e o consumo do free tier não é.
  EOT
  type        = string
  default     = "30s"
}
