# A rede e o cluster nascem em tc3-infra-k8s; aqui só consumimos.
data "terraform_remote_state" "k8s" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = "infra-k8s/terraform.tfstate"
    region = var.aws_region
  }
}

locals {
  identificador = "${var.project_name}-${var.environment}"

  vpc_id                 = data.terraform_remote_state.k8s.outputs.vpc_id
  private_subnet_ids     = data.terraform_remote_state.k8s.outputs.private_subnet_ids
  node_security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group_id
}

# Buscado por nome em vez de vir pelo state remoto: o certificado do cluster não
# é output de tc3-infra-k8s, e acrescentar output só para isto acopla os dois
# repositórios sem necessidade.
data "aws_eks_cluster" "principal" {
  name = local.identificador
}

# Publicada por tc3-infra-k8s. Ler daqui evita repetir a chave como secret de
# repositório em mais um lugar.
data "aws_ssm_parameter" "newrelic_license_key" {
  name = "/${var.project_name}/${var.environment}/NEW_RELIC_LICENSE_KEY"
}
