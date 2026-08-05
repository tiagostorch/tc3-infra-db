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
