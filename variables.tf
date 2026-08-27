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
